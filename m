From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH IPROUTE2] tc-codel: Update usage text
Date: Thu, 24 May 2012 15:02:27 -0700
Message-ID: <20120524150227.7571027e@nehalam.linuxnetplumber.net>
References: <1337885287-31354-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Taht <dave.taht@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36312 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752175Ab2EXWC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 18:02:29 -0400
In-Reply-To: <1337885287-31354-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 May 2012 11:48:07 -0700
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> codel can take 'noecn' as an option. This also makes it consistent with the
> manpage.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  tc/q_codel.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/tc/q_codel.c b/tc/q_codel.c
> index 826285a..dc4b3f6 100644
> --- a/tc/q_codel.c
> +++ b/tc/q_codel.c
> @@ -54,7 +54,7 @@
>  static void explain(void)
>  {
>  	fprintf(stderr, "Usage: ... codel [ limit PACKETS ] [ target TIME]\n");
> -	fprintf(stderr, "                 [ interval TIME ] [ ecn ]\n");
> +	fprintf(stderr, "                 [ interval TIME ] [ ecn | noecn ]\n");
>  }
>  
>  static int codel_parse_opt(struct qdisc_util *qu, int argc, char **argv,

Applied, thanks.
