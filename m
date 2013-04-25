From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] iplink: add batadv interface type
Date: Thu, 25 Apr 2013 09:12:55 -0700
Message-ID: <20130425091255.7e922492@nehalam.linuxnetplumber.net>
References: <1366878799-20237-1-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:35568 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757220Ab3DYQNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 12:13:00 -0400
Received: by mail-pb0-f52.google.com with SMTP id mc17so623182pbc.25
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 09:13:00 -0700 (PDT)
In-Reply-To: <1366878799-20237-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Apr 2013 10:33:19 +0200
Antonio Quartulli <ordex@autistici.org> wrote:

> batadv is another virtual interface type that can be created
> via ip link. Add its name to the help screen.
> 
> Signed-off-by: Antonio Quartulli <ordex@autistici.org>
> ---
>  ip/iplink.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/iplink.c b/ip/iplink.c
> index dc98019..2301cbc 100644
> --- a/ip/iplink.c
> +++ b/ip/iplink.c
> @@ -84,7 +84,7 @@ void iplink_usage(void)
>  	if (iplink_have_newlink()) {
>  		fprintf(stderr, "\n");
>  		fprintf(stderr, "TYPE := { vlan | veth | vcan | dummy | ifb | macvlan | can |\n");
> -		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan }\n");
> +		fprintf(stderr, "          bridge | ipoib | ip6tnl | ipip | sit | vxlan | batadv }\n");
>  	}
>  	exit(-1);
>  }

First, this only works on net-next (not upstream), so not applying to current version iproute.
