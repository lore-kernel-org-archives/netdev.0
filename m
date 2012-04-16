From: "Ward, David - 0663 - MITLL" <david.ward@ll.mit.edu>
Subject: Re: [PATCH] net_sched: red: Make minor corrections to comments
Date: Mon, 16 Apr 2012 09:06:02 -0400
Message-ID: <4F8C193A.5090806@ll.mit.edu>
References: <1334529106-5035-1-git-send-email-david.ward@ll.mit.edu>
 <1334529106-5035-2-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:57750 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753626Ab2DPNGG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 09:06:06 -0400
Received: from LLE2K7-HUB02.mitll.ad.local (LLE2K7-HUB02.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id q3GD64iG008218 for <netdev@vger.kernel.org>; Mon, 16 Apr 2012 09:06:04 -0400
In-Reply-To: <1334529106-5035-2-git-send-email-david.ward@ll.mit.edu>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/15/2012 06:31 PM, Ward, David - 0663 - MITLL wrote:
> diff --git a/include/net/red.h b/include/net/red.h
> index 77d4c37..c0bc25e 100644
> --- a/include/net/red.h
> +++ b/include/net/red.h
> @@ -28,7 +28,7 @@
>   	the inertia of the algorithm. To allow larger bursts, W should be
>   	decreased.
>
> -	if (avg>  th_max) ->  packet marked (dropped).
> +	if (avg>  th_max) ->  packet marked (dropped) with probability max_P.
>   	if (avg<  th_min) ->  packet passes.
>   	if (th_min<  avg<  th_max) we calculate probability:
>
Sorry, this line was correct as it was. (Misleading man page tc-red(8) 
says "Because probability is normally not set to 100%, the queue size 
might conceivably rise above max bytes")

Re-sending with just the other changes (and a patch for that man page).