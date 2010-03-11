From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [PATCH 0/7] tcp: bugs and cleanup for 2.6.34-rc1
Date: Thu, 11 Mar 2010 12:38:17 -0500
Message-ID: <4B992A89.6040700@gmail.com>
References: <4B98D592.6040301@gmail.com> <1268319664.2986.535.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	=?UTF-8?B?UGVudHRpbMOkIE1pa2E=?= <mika.penttila@ixonos.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.24]:12826 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932346Ab0CKRiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 12:38:21 -0500
In-Reply-To: <1268319664.2986.535.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/11/10 10:01 AM, Eric Dumazet wrote:
> It would be nice if you could update your knowledge of how linux
> development works these days.
>
Perhaps you could supply pointers to the relevant documentation?


> You throw too many changes at once to let them being reviewed,
> understood, and accepted.
>
These were originally submitted in groups of 1, 2, and 3 patches for
review.  For example, as TCPCT parts 1h and 1i (and had been part of
earlier patch series, too), as of 2009-12-03:

   http://patchwork.ozlabs.org/patch/40284/

Resubmitted again in even finer grained patches, as of 2009-12-31 and
again 2010-01-06:

   http://lkml.org/lkml/2010/1/6/299

Since February, I've grouped them all together, as they've been reviewed,
and re-reviewed -- yet only deprecated by the netdev maintainer.


> For your information, we had to correct a fatal bug introduced by your
> last commits, and as far as I know, you didnt help that much.
>
> http://git2.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=28b2774a0d5852236dab77a4147b8b88548110f1
>
Splendid!  Thank you for the heads up!  Unfortunately, that 3 day old
email wasn't CC'd to me.  I'm glad to hear that Mika is testing.

And thank you for testing the patch.  (You did test, didn't you?)
Testing is always good!

That code always worked for me, and presumably for Adam (who wrote it).
We've always used small amounts of data -- only 64 bytes, as originally
specified.  The latest API document allows up to 1220.  Folks just keep
wanting more!

(The latest API also drops the subscript, so that patch would have been
changed eventually....)

This code (PATCH v3 5/7) handles the data on the receiving side of the
same transaction, a patch that was first submitted over 18 months ago!


> <at this moment of time>
>
> We are post linux-2.6.34-rc1, so only bug fixes are wanted by Linus and
> David, to be integrated in 2.6.34 (and previous versions if needed)
>
> We are _not_ interested by new stuff at *this* moment, especially if it
> takes lot of time to review.
>
> </at this moment of time>
>
Good.  Because this isn't new stuff.  It's bug fixes and related cleanup.
Generally, the cleanup was needed to find and test the bugs and patches.

They're already "split up" from the main set of patches, as Ilpo asked
over 4 months ago.

I've not been making *any* new submissions around here, until *existing*
submissions have been applied.


> Last time I made some comments on your patches, you just ignored them or
> loaned, because obviously who is Eric Dumazet to tell William Allen
> Simpson how things should be done ? Silly me !
>
Last time you made any comments at all, it was trivial argument about
parenthesis and casts.  I asked directly for more *substantive* review:

   http://lkml.org/lkml/2010/1/13/162

Thankfully, we've had substantive review from Andi over a period of
months, on parts 3 and 4 of the current patch series....

And a short attaboy of part 2 a couple of weeks ago.


> Speaking for myself, but as your previous mails were ignored, I felt it
> was time to clarify the points.
>
Thank you.
