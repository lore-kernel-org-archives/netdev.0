From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH resend] ip: add nlmon as a device type to help message
Date: Tue, 15 Jul 2014 09:42:51 -0700
Message-ID: <20140715094251.748ceec3@haswell>
References: <1405414636-31362-1-git-send-email-yamato@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Masatake YAMATO <yamato@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:39117 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752402AbaGOQmt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 12:42:49 -0400
Received: by mail-pa0-f47.google.com with SMTP id kx10so6189888pab.6
        for <netdev@vger.kernel.org>; Tue, 15 Jul 2014 09:42:49 -0700 (PDT)
In-Reply-To: <1405414636-31362-1-git-send-email-yamato@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jul 2014 17:57:16 +0900
Masatake YAMATO <yamato@redhat.com> wrote:

> Though nlmon device can be added, it was not listed
> in the output of "ip link help".
> 
> Acked-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Masatake YAMATO <yamato@redhat.com>
> ---
>  ip/iplink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index de9ef5d..5e428da 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -87,7 +87,7 @@ void iplink_usage(void)
>  		fprintf(stderr, "\n");
>  		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | macvtap |\n");
>  		fprintf(stderr, "          bridge | bond | ipoib | ip6tnl | ipip | sit | vxlan |\n");
> -		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti }\n");
> +		fprintf(stderr, "          gre | gretap | ip6gre | ip6gretap | vti | nlmon }\n");
>  	}
>  	exit(-1);
>  }

accepted
