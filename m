From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] vxlan: Allow setting unicast address to the
 group address
Date: Wed, 10 Apr 2013 09:46:39 -0700
Message-ID: <20130410094639.748d022f@nehalam.linuxnetplumber.net>
References: <87sj2yn4y2.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:63079 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936021Ab3DJQrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 12:47:01 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so291082dad.18
        for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 09:47:00 -0700 (PDT)
In-Reply-To: <87sj2yn4y2.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Apr 2013 17:52:05 +0900
Atzm Watanabe <atzm@stratosphere.co.jp> wrote:

> This patch allows setting unicast address to the VXLAN group address.
> It allows that VXLAN can be used as peer-to-peer tunnel without
> multicast.
> 
> Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
> ---
>  ip/iplink_vxlan.c | 3 ---
>  1 file changed, 3 deletions(-)
> 
> diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
> index 1025326..cfe324c 100644
> --- a/ip/iplink_vxlan.c
> +++ b/ip/iplink_vxlan.c
> @@ -66,9 +66,6 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
>  		} else if (!matches(*argv, "group")) {
>  			NEXT_ARG();
>  			gaddr = get_addr32(*argv);
> -
> -			if (!IN_MULTICAST(ntohl(gaddr)))
> -				invarg("invald group address", *argv);
>  		} else if (!matches(*argv, "local")) {
>  			NEXT_ARG();
>  			if (strcmp(*argv, "any"))

Could you use another name or argument to express the different intended behavior.
