From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH iproute2] man ip-link: Add missing link types -
 vti,ipvlan,nlmon
Date: Mon, 06 Apr 2015 11:59:24 -0500
Message-ID: <1428339564.16890.3.camel@redhat.com>
References: <1428163255-1509-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44417 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891AbbDFQ6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Apr 2015 12:58:51 -0400
In-Reply-To: <1428163255-1509-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-04-04 at 19:00 +0300, Vadim Kochan wrote:
> From: Vadim Kochan <vadim4j@gmail.com>
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  man/man8/ip-link.8.in | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
> 
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 0e3bb5e..642cdb2 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -72,7 +72,10 @@ ip-link \- network device configuration
>  .BR gre " |"
>  .BR gretap " |"
>  .BR ip6gre " |"
> -.BR ip6gretap " ]"
> +.BR ip6gretap " |"
> +.BR vti " |"
> +.BR nlmon " |"
> +.BR ipvlan " ]"
>  
>  .ti -8
>  .BI "ip link delete " DEVICE
> @@ -228,6 +231,15 @@ Link types:
>  .sp
>  .BR ip6gretap
>  - Virtual L2 tunnel interface GRE over IPv6
> +.sp
> +.BR vti
> +- Virtual tunnel interface
> +.sp
> +.BR nlmon
> +- Netlink monitoring device
> +.sp
> +.BR ipvlan
> +- Interface for L3 (IPv6/IPv4) based VLANs

ipvlan does L2 as well.

Dan
