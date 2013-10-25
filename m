From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH] Documentation/networking: netdev-FAQ typo corrections
Date: Fri, 25 Oct 2013 14:56:20 -0400
Message-ID: <526ABED4.8020605@windriver.com>
References: <5269CFE9.3020703@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44057 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751321Ab3JYS44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Oct 2013 14:56:56 -0400
In-Reply-To: <5269CFE9.3020703@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-10-24 09:56 PM, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Various typo fixes to netdev-FAQ.txt:
> - capitalize Linux
> - hyphenate dual-word adjectives
> - minor punctuation fixes
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
> Cc: Paul Gortmaker <paul.gortmaker@windriver.com>

I've no objections to those kinds of changes.

Acked-by: Paul Gortmaker <paul.gortmaker@windriver.com>

P.
--

> ---
>  Documentation/networking/netdev-FAQ.txt |   22 +++++++++++-----------
>  1 file changed, 11 insertions(+), 11 deletions(-)
> 
> --- lnx-312-rc6.orig/Documentation/networking/netdev-FAQ.txt
> +++ lnx-312-rc6/Documentation/networking/netdev-FAQ.txt
> @@ -4,23 +4,23 @@ Information you need to know about netde
>  
>  Q: What is netdev?
>  
> -A: It is a mailing list for all network related linux stuff.  This includes
> +A: It is a mailing list for all network-related Linux stuff.  This includes
>     anything found under net/  (i.e. core code like IPv6) and drivers/net
> -   (i.e. hardware specific drivers) in the linux source tree.
> +   (i.e. hardware specific drivers) in the Linux source tree.
>  
>     Note that some subsystems (e.g. wireless drivers) which have a high volume
>     of traffic have their own specific mailing lists.
>  
> -   The netdev list is managed (like many other linux mailing lists) through
> +   The netdev list is managed (like many other Linux mailing lists) through
>     VGER ( http://vger.kernel.org/ ) and archives can be found below:
>  
>  	http://marc.info/?l=linux-netdev
>  	http://www.spinics.net/lists/netdev/
>  
> -   Aside from subsystems like that mentioned above, all network related linux
> -   development (i.e. RFC, review, comments, etc) takes place on netdev.
> +   Aside from subsystems like that mentioned above, all network-related Linux
> +   development (i.e. RFC, review, comments, etc.) takes place on netdev.
>  
> -Q: How do the changes posted to netdev make their way into linux?
> +Q: How do the changes posted to netdev make their way into Linux?
>  
>  A: There are always two trees (git repositories) in play.  Both are driven
>     by David Miller, the main network maintainer.  There is the "net" tree,
> @@ -35,7 +35,7 @@ A: There are always two trees (git repos
>  Q: How often do changes from these trees make it to the mainline Linus tree?
>  
>  A: To understand this, you need to know a bit of background information
> -   on the cadence of linux development.  Each new release starts off with
> +   on the cadence of Linux development.  Each new release starts off with
>     a two week "merge window" where the main maintainers feed their new
>     stuff to Linus for merging into the mainline tree.  After the two weeks,
>     the merge window is closed, and it is called/tagged "-rc1".  No new
> @@ -46,7 +46,7 @@ A: To understand this, you need to know
>     things are in a state of churn), and a week after the last vX.Y-rcN
>     was done, the official "vX.Y" is released.
>  
> -   Relating that to netdev:  At the beginning of the 2 week merge window,
> +   Relating that to netdev:  At the beginning of the 2-week merge window,
>     the net-next tree will be closed - no new changes/features.  The
>     accumulated new content of the past ~10 weeks will be passed onto
>     mainline/Linus via a pull request for vX.Y -- at the same time,
> @@ -59,12 +59,12 @@ A: To understand this, you need to know
>     IMPORTANT:  Do not send new net-next content to netdev during the
>     period during which net-next tree is closed.
>  
> -   Shortly after the two weeks have passed, (and vX.Y-rc1 is released) the
> +   Shortly after the two weeks have passed (and vX.Y-rc1 is released), the
>     tree for net-next reopens to collect content for the next (vX.Y+1) release.
>  
>     If you aren't subscribed to netdev and/or are simply unsure if net-next
>     has re-opened yet, simply check the net-next git repository link above for
> -   any new networking related commits.
> +   any new networking-related commits.
>  
>     The "net" tree continues to collect fixes for the vX.Y content, and
>     is fed back to Linus at regular (~weekly) intervals.  Meaning that the
> @@ -217,7 +217,7 @@ A: Attention to detail.  Re-read your ow
>     to why it happens, and then if necessary, explain why the fix proposed
>     is the best way to get things done.   Don't mangle whitespace, and as
>     is common, don't mis-indent function arguments that span multiple lines.
> -   If it is your 1st patch, mail it to yourself so you can test apply
> +   If it is your first patch, mail it to yourself so you can test apply
>     it to an unpatched tree to confirm infrastructure didn't mangle it.
>  
>     Finally, go back and read Documentation/SubmittingPatches to be
> 
