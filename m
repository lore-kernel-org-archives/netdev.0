From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 2/2] tc-drr(8): tab unquoted in a argument to a macro
Date: Tue, 29 May 2012 08:18:38 -0700
Message-ID: <20120529081838.4b8cf24b@nehalam.linuxnetplumber.net>
References: <1338205565-11872-1-git-send-email-andreas@fatal.se>
	<1338205565-11872-2-git-send-email-andreas@fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bjarni Ingi Gislason <bjarniig@rhi.hi.is>
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39984 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523Ab2E2PSn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 May 2012 11:18:43 -0400
In-Reply-To: <1338205565-11872-2-git-send-email-andreas@fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 28 May 2012 13:46:05 +0200
Andreas Henriksson <andreas@fatal.se> wrote:

> From: Bjarni Ingi Gislason <bjarniig@rhi.hi.is>
> 
> From "man ..." ("groff -ww -mandoc ..."):
> 
> <groff: tc-drr.8>:67: warning: tab character in unquoted macro argument
> <groff: tc-drr.8>:69: warning: tab character in unquoted macro argument
> 
> *********************
> 
> Originally filed at: http://bugs.debian.org/674706
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> ---
>  man/man8/tc-drr.8 |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/man/man8/tc-drr.8 b/man/man8/tc-drr.8
> index 16a8ec0..e25d6dd 100644
> --- a/man/man8/tc-drr.8
> +++ b/man/man8/tc-drr.8
> @@ -64,9 +64,9 @@ flow filter:
>  
>  .B for i in .. 1024;do
>  .br
> -.B \ttc class add dev ..  classid $handle:$(print %x $i)
> +.B "\ttc class add dev .. classid $handle:$(print %x $i)"
>  .br
> -.B \ttc qdisc add dev .. fifo limit 16
> +.B "\ttc qdisc add dev .. fifo limit 16"
>  .br
>  .B done
>  

Both applied, thanks.
