From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: Export IGMP/MLD message validation
	code
Date: Mon, 13 Apr 2015 13:32:28 -0400 (EDT)
Message-ID: <20150413.133228.1185934929215664377.davem@davemloft.net>
References: <1428687999-18428-1-git-send-email-linus.luessing@c0d3.blue>
	<1428687999-18428-2-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: bridge@lists.linux-foundation.org, herbert@gondor.apana.org.au,
	yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	b.a.t.m.a.n@lists.open-mesh.org, linux-kernel@vger.kernel.org,
	therbert@google.com
To: linus.luessing@c0d3.blue
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1428687999-18428-2-git-send-email-linus.luessing@c0d3.blue>
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
Date: Fri, 10 Apr 2015 19:46:39 +0200

> With this patch, the IGMP and MLD message validation functions are mo=
ved
> from the bridge code to IPv4/IPv6 multicast files. Some small
> refactoring was done to enhance readibility and to iron out some
> differences in behaviour between the IGMP and MLD parsing code (e.g. =
the
> skb-cloning of MLD messages is now only done if necessary, just like =
the
> IGMP part always did).
> =

> Finally, these IGMP and MLD message validation functions are exported=
 so
> that not only the bridge can use it but batman-adv later, too.
> =

> Signed-off-by: Linus L=FCssing <linus.luessing@c0d3.blue>

Please update the copyrights as per your discussion with YOSHIFUJI
Hideaki.

Also, please provide a cover "[PATCH 0/2] " posting with a top-level
summary of what this series is doing so I can use that text in the
message of the merge commit I'll create when applying your series.

Thanks.
