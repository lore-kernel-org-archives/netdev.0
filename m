From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc: prio: Perform more strict check on priomap.
Date: Mon, 18 Jun 2012 12:25:54 -0700
Message-ID: <20120618122554.403f53ec@nehalam.linuxnetplumber.net>
References: <4FDECBC2.1090304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37116 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752553Ab2FRTZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 15:25:57 -0400
In-Reply-To: <4FDECBC2.1090304@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jun 2012 14:33:38 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> 
> Since band number counts from zero thus band must be little than
> opt.bands.
> ---
>  tc/q_prio.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/tc/q_prio.c b/tc/q_prio.c
> index 79b4fd0..bacc702 100644
> --- a/tc/q_prio.c
> +++ b/tc/q_prio.c
> @@ -67,7 +67,7 @@ static int prio_parse_opt(struct qdisc_util *qu, int argc, char **argv, struct n
>  				fprintf(stderr, "Illegal \"priomap\" element\n");
>  				return -1;
>  			}
> -			if (band > opt.bands) {
> +			if (band >= opt.bands) {
>  				fprintf(stderr, "\"priomap\" element is out of bands\n");
>  				return -1;
>  			}

Applied
