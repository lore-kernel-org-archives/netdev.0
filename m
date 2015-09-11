From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: fix igmpv3 / mldv2 report parsing
Date: Fri, 11 Sep 2015 15:09:04 -0700 (PDT)
Message-ID: <20150911.150904.2037048001164493906.davem@davemloft.net>
References: <1441989588-26312-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, tobias.powalowski@googlemail.com
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1441989588-26312-1-git-send-email-linus.luessing@c0d3.blue>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

From: Linus L=FCssing <linus.luessing@c0d3.blue>
Date: Fri, 11 Sep 2015 18:39:48 +0200

> With the newly introduced helper functions the skb pulling is hidden =
in
> the checksumming function - and undone before returning to the caller=
.=

> =

> The IGMPv3 and MLDv2 report parsing functions in the bridge still
> assumed that the skb is pointing to the beginning of the IGMP/MLD
> message while it is now kept at the beginning of the IPv4/6 header,
> breaking the message parsing and creating packet loss.
> =

> Fixing this by taking the offset between IP and IGMP/MLD header into
> account, too.
> =

> Fixes: 9afd85c9e455 ("net: Export IGMP/MLD message validation code")
> Reported-by: Tobias Powalowski <tobias.powalowski@googlemail.com>
> Tested-by: Tobias Powalowski <tobias.powalowski@googlemail.com>
> Signed-off-by: Linus L=FCssing <linus.luessing@c0d3.blue>

There were many serious regressions introduced by that commit, I'm
extremely disappointed.

Patch applied and queued up for -stable, thanks.
