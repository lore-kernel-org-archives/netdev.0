From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] bridge: disable snooping if there is no
	querier
Date: Wed, 31 Jul 2013 17:40:37 -0700 (PDT)
Message-ID: <20130731.174037.1794753574143053874.davem@davemloft.net>
References: <20130730.161035.1646022729333223847.davem@davemloft.net>
	<1375311980-25575-1-git-send-email-linus.luessing@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux@baker-net.org.uk, stephen@networkplumber.org,
	herbert@gondor.apana.org.au
To: linus.luessing@web.de
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1375311980-25575-1-git-send-email-linus.luessing@web.de>
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

From: Linus L=FCssing <linus.luessing@web.de>
Date: Thu,  1 Aug 2013 01:06:20 +0200

> If there is no querier on a link then we won't get periodic reports a=
nd
> therefore won't be able to learn about multicast listeners behind por=
ts,
> potentially leading to lost multicast packets, especially for multica=
st
> listeners that joined before the creation of the bridge.
> =

> These lost multicast packets can appear since c5c23260594
> ("bridge: Add multicast_querier toggle and disable queries by default=
")
> in particular.
> =

> With this patch we are flooding multicast packets if our querier is
> disabled and if we didn't detect any other querier.
> =

> A grace period of the Maximum Response Delay of the querier is added =
to
> give multicast responses enough time to arrive and to be learned from=

> before disabling the flooding behaviour again.
> =

> Signed-off-by: Linus L=FCssing <linus.luessing@web.de>

Looks good, applied, thanks Linus.
