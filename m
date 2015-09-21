From: Stephen Hemminger <shemming@brocade.com>
Subject: Re: [iproute PATCH] man: tc.8: mention Fair Queue scheduler
Date: Mon, 21 Sep 2015 14:30:48 -0700
Message-ID: <20150921143048.071cea77@urahara>
References: <1441806068-14585-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:37664 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752600AbbIUVao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 17:30:44 -0400
In-Reply-To: <1441806068-14585-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  9 Sep 2015 15:41:08 +0200
Phil Sutter <phil@nwl.cc> wrote:

> This is rather a placeholder to let users know fq exists at all.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  man/man8/tc.8 | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/man/man8/tc.8 b/man/man8/tc.8
> index feafa05..0081625 100644
> --- a/man/man8/tc.8
> +++ b/man/man8/tc.8
> @@ -151,6 +151,10 @@ The classless qdiscs are:
>  Simplest usable qdisc, pure First In, First Out behaviour. Limited in
>  packets or in bytes.
>  .TP
> +fq
> +Fair Queue Scheduler realises TCP pacing and scales to millions of concurrent
> +flows per qdisc.
> +.TP
>  pfifo_fast
>  Standard qdisc for 'Advanced Router' enabled kernels. Consists of a three-band
>  queue which honors Type of Service flags, as well as the priority that may be

Why just fq?
Why not mention all of the others like codel and fq_codel?
