From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: fix typo in help message.
Date: Mon, 20 Aug 2012 09:00:23 -0700
Message-ID: <20120820090023.5d0bcd7a@nehalam.linuxnetplumber.net>
References: <1345444127-27932-1-git-send-email-lw@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56316 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860Ab2HTQAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 12:00:43 -0400
In-Reply-To: <1345444127-27932-1-git-send-email-lw@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Aug 2012 14:28:47 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> Signed-off-by: Li Wei <lw@cn.fujitsu.com>
> ---
>  bridge/fdb.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/bridge/fdb.c b/bridge/fdb.c
> index 2bbdaa6..c6aa08e 100644
> --- a/bridge/fdb.c
> +++ b/bridge/fdb.c
> @@ -239,6 +239,6 @@ int do_fdb(int argc, char **argv)
>  	} else
>  		return fdb_show(0, NULL);
>  
> -	fprintf(stderr, "Command \"%s\" is unknown, try \"ip neigh help\".\n", *argv);
> +	fprintf(stderr, "Command \"%s\" is unknown, try \"bridge fdb help\".\n", *argv);
>  	exit(-1);
>  }

Applied
