From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 2/2] iproute2 vxlan documentation update for ip command
Date: Fri, 05 Jul 2013 10:22:16 +0200
Message-ID: <87siztju13.fsf@nemi.mork.no>
References: <1373008131-8057-1-git-send-email-tmricht@linux.vnet.ibm.com>
	<1373008131-8057-2-git-send-email-tmricht@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Thomas Richter <tmricht@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:60888 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757179Ab3GEIWl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 04:22:41 -0400
In-Reply-To: <1373008131-8057-2-git-send-email-tmricht@linux.vnet.ibm.com>
	(Thomas Richter's message of "Fri, 5 Jul 2013 09:08:51 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Richter <tmricht@linux.vnet.ibm.com> writes:

> The ip link command line help and the ip-link.8.in
> man page are outdated in regards to the vxlan support.
> The patch updates both the command line help for the
> ip command and its man page.
>
> Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
> ---
>  ip/iplink.c           |  2 +-
>  man/man8/ip-link.8.in | 85 +++++++++++++++++++++++++++++++++++++++++=
++++++++++
>  2 files changed, 86 insertions(+), 1 deletion(-)
>
> diff --git a/ip/iplink.c b/ip/iplink.c
> index dc98019..f677329 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -83,7 +83,7 @@ void iplink_usage(void)
> =20
>  	if (iplink_have_newlink()) {
>  		fprintf(stderr, "\n");
> -		fprintf(stderr, "TYPE :=3D { vlan | veth | vcan | dummy | ifb | ma=
cvlan | can |\n");
> +		fprintf(stderr, "TYPE :=3D { vlan | vxlan | veth | vcan | dummy | =
ifb | macvlan | can |\n");
>  		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | =
vxlan }\n");

There was already a vxlan entry there.  Now there's two.


Bj=C3=B8rn
