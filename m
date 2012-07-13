From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc-bfifo: man: Add parameter value range.
Date: Fri, 13 Jul 2012 10:01:59 -0700
Message-ID: <20120713100159.44459e35@nehalam.linuxnetplumber.net>
References: <4FFFC950.6020806@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Li Wei <lw@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36073 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932288Ab2GMRCS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2012 13:02:18 -0400
In-Reply-To: <4FFFC950.6020806@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Jul 2012 15:08:00 +0800
Li Wei <lw@cn.fujitsu.com> wrote:

> 
> Add value range for 'limit' parameter.
> ---
>  man/man8/tc-bfifo.8 |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/man/man8/tc-bfifo.8 b/man/man8/tc-bfifo.8
> index 8dda4bb..417e45c 100644
> --- a/man/man8/tc-bfifo.8
> +++ b/man/man8/tc-bfifo.8
> @@ -40,8 +40,12 @@ to the interface txqueuelen, as specified with
>  .BR ifconfig (8)
>  or
>  .BR ip (8).
> +The range for this parameter is [0, UINT32_MAX].
>  
>  For bfifo, it defaults to the txqueuelen multiplied by the interface MTU.
> +The range for this parameter is [0, UINT32_MAX] bytes.
> +
> +Note: The link layer header was considered when couting packets length.
>  

Applied. Fixed spelling of "couting"
