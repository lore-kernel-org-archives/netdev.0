From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip monitor: Changed 'Unknown message' format
 to be more informative
Date: Sun, 28 Sep 2014 16:15:51 -0700
Message-ID: <20140928161551.32f0034b@urahara>
References: <1410891830-4556-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:63270 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751985AbaI1XQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 19:16:07 -0400
Received: by mail-pd0-f176.google.com with SMTP id fp1so3043572pdb.35
        for <netdev@vger.kernel.org>; Sun, 28 Sep 2014 16:16:07 -0700 (PDT)
In-Reply-To: <1410891830-4556-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 16 Sep 2014 21:23:50 +0300
Vadim Kochan <vadim4j@gmail.com> wrote:

> In case if unknown message was handled then it will be displayed as:
> 
>     Unknown message: type=0x00000044(68) flags=0x00000000(0) len=0x0000004c(76)
> 
> Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
> ---
>  ip/ipmonitor.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
> index 70f2a7a..838934d 100644
> --- a/ip/ipmonitor.c
> +++ b/ip/ipmonitor.c
> @@ -135,8 +135,10 @@ static int accept_msg(const struct sockaddr_nl *who,
>  		return 0;
>  	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
>  	    n->nlmsg_type != NLMSG_DONE) {
> -		fprintf(fp, "Unknown message: %08x %08x %08x\n",
> -			n->nlmsg_len, n->nlmsg_type, n->nlmsg_flags);
> +		fprintf(fp, "Unknown message: type=0x%08x(%d) flags=0x%08x(%d)"
> +			"len=0x%08x(%d)\n", n->nlmsg_type, n->nlmsg_type,
> +		       	n->nlmsg_flags, n->nlmsg_flags, n->nlmsg_len,
> +		       	n->nlmsg_len);
>  	}
>  	return 0;
>  }

Patch is formatted improperly, it should be indented only with tabs.
