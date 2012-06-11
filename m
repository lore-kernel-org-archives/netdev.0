From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH IPROUTE2 V2] tc: Update manpage
Date: Mon, 11 Jun 2012 15:04:21 -0700
Message-ID: <20120611150421.75203875@nehalam.linuxnetplumber.net>
References: <1338921686-10372-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	jan.ceuleers@computer.org
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52478 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751840Ab2FKWE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 18:04:26 -0400
In-Reply-To: <1338921686-10372-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  5 Jun 2012 11:41:26 -0700
Vijay Subramanian <subramanian.vijay@gmail.com> wrote:

> This makes 2 changes:
> 1: Add fq_codel to SEE ALSO section in tc manpage.
> 2: Reorder the SEE ALSO section to make the order alphabetical
> (suggested by Jan Ceuleers ).
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  V2: Reorder the SEE ALSO section to make it alphabetical.
> 
>  man/man8/tc.8 |   15 ++++++++-------
>  1 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/man/man8/tc.8 b/man/man8/tc.8
> index 14a1cd8..958ab98 100644
> --- a/man/man8/tc.8
> +++ b/man/man8/tc.8
> @@ -366,21 +366,22 @@ print rates in IEC units (ie. 1K = 1024).
>  .B tc
>  was written by Alexey N. Kuznetsov and added in Linux 2.2.
>  .SH SEE ALSO
> +.BR tc-bfifo (8),
>  .BR tc-cbq (8),
>  .BR tc-choke (8),
>  .BR tc-codel (8),
>  .BR tc-drr (8),
> -.BR tc-htb (8),
> -.BR tc-hfsc (8),
> +.BR tc-fq_codel (8),
>  .BR tc-hfsc (7),
> -.BR tc-sfb (8),
> -.BR tc-sfq (8),
> -.BR tc-red (8),
> -.BR tc-tbf (8),
> +.BR tc-hfsc (8),
> +.BR tc-htb (8),
>  .BR tc-pfifo (8),
> -.BR tc-bfifo (8),
>  .BR tc-pfifo_fast (8),
> +.BR tc-red (8),
> +.BR tc-sfb (8),
> +.BR tc-sfq (8),
>  .BR tc-stab (8),
> +.BR tc-tbf (8),
>  .br
>  .RB "User documentation at " http://lartc.org/ ", but please direct bugreports and patches to: " <netdev@vger.kernel.org>
>  

Applied
