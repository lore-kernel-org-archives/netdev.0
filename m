From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH iproute2 3/4] iproute: Description of new options for
 VXLAN in ip-link man pages
Date: Thu, 29 Jan 2015 18:20:59 +0100
Message-ID: <54CA6BFB.9000109@redhat.com>
References: <1422550321-30901-1-git-send-email-therbert@google.com> <1422550321-30901-4-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Tom Herbert <therbert@google.com>, stephen@networkplumber.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51247 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752139AbbA2RVF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2015 12:21:05 -0500
In-Reply-To: <1422550321-30901-4-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/29/2015 05:52 PM, Tom Herbert wrote:
> Add description for UDP checksums and remote checksum offload.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  man/man8/ip-link.8.in | 18 ++++++++++++++++++
>  1 file changed, 18 insertions(+)
> 
> diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
> index 1209b55..a0be895 100644
> --- a/man/man8/ip-link.8.in
> +++ b/man/man8/ip-link.8.in
> @@ -276,6 +276,12 @@ the following additional arguments are supported:
>  .BI ageing " SECONDS "
>  .R " ] [ "
>  .BI maxaddress " NUMBER "
> +.R " ] [ "
> +.I "[no]udpcsum "
> +.R " ] [ "
> +.I "[no]remcsumtx "
> +.R " ] [ "
> +.I "[no]remcsumrx "
>  .R " ]"
>  
>  .in +8
> @@ -348,6 +354,18 @@ are entered into the VXLAN device forwarding database.
>  .BI maxaddress " NUMBER"
>  - specifies the maximum number of FDB entries.
>  
> +.sp
> +.I [no]udpcsum
> +- specifies if UDP checksum is enabled in the outer header.
> +
> +.sp
> +.I [no]remcsumtx
> +- specifies if remote checksum option is tranmitted.
                                            ^^^^^^^^^^
transmitted

> +
> +.sp
> +.I [no]remcsumrx
> +- specifies if remote checksum option is allowed to be received.
> +
>  .in -8
>  
>  .TP
> 
