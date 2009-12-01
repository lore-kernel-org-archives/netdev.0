From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: warning: massive change to conditional coding style in net?
Date: Tue, 01 Dec 2009 12:56:40 -0500
Message-ID: <4B1558D8.4010804@gmail.com>
References: <4B13A025.7000103@gmail.com> <20091130.123644.203668577.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.211.182]:35959 "EHLO
	mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbZLAR4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 12:56:37 -0500
In-Reply-To: <20091130.123644.203668577.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> William, you're unreasonable.
> 
I've waited a day before replying to this message, so that my anger
at your false and misleading statements could be carefully removed.

Maybe you're smiling and genial as you write your responses, but it
comes across as throwing a temper tantrum.

Meantime, I brought this topic to a broader audience to see whether
there was some general consensus that could be documented.

Your personal /ad hominem/ attacks are not appreciated.


> We asked you to follow a certain style, and then you immediately
> complain that the style isn't followed consistently in the tree, and
> therefore as a consequence you shouldn't be required to follow it.
> 
Whenever you've asked for an arbitrary and capricious change, I've
pointed to existing code -- not _com_plaining, *ex*plaining.

Before beginning, I read the Documentation.  I started with an existing
patch that had already been approved by you during its RFC review, and
carefully followed the existing coding practices.

In each section of code, I've followed its *existing* style.  Because
different sections of the code often have different styles, that means
the patch will be cleaner.  IMnsHO, clean patches are easier to review.

Where the code section was entirely new, I followed a style that is
well represented in the Linux tree as a whole (and the TCP code in
particular), although it is not a majority style.


> Then Joe comes and submits patches making the tree follow the style
> more consistently.  See, instead of merely complaining like you did,
> he proactively did something positive.
> 
First of all, this is not *THE* style.  Your style is not documented in
CodingStyle.  It may be your preference, but there is no agreement, not
even in patches that you've approved and applied in recent months.

Secondly, Joe was not "proactive".  You solicited the patches:

   http://patchwork.ozlabs.org/patch/39072/

Thirdly, there is disagreement about the "positive" nature.  For example:

   "Rather than playing with the dangling operator format which seems to
   be a coding style that only David cares about...."

   http://patchwork.kernel.org/patch/63847/


> Now you're complaining because this makes your patches harder to
> maintain.
> 
You betcha!  And I'm quite sure I'm not the only contributor impacted.


> Whereas if you had merely fixed up the coding style as I and others
> have asked you, your code would be in my tree weeks ago.
> 
NOT TRUE!  This was a *recent* request by you, and a change to code
previous Ack'd weeks ago by other reviewers.

Another recent example is initializing a sysctl (present in every patch
for TWO MONTHS) that you've suddenly declared "extremely non-intuitive",
and "doesn't make any sense."  As I pointed to the origin in syncookies,
you changed syncookies....  (Andi Kleen, such a bad coder.)

An example from a few iterations ago: you required the "const" be
removed from my inline functions, notwithstanding that EVERY OTHER
FUNCTION in the linux/tcp.h header uses that form.  Of course, using
const there is standard C.

Over and over, I've followed existing coding practices.  Over and over,
you've thrown roadblocks into the process, since your comment that this
was "some odd-ball feature" back in early October....

Each time I've posted a patch series, one or two usually trivial changes
are requested.  Heck, changes to comments!

If these changes had been mentioned a month or two ago, as part of a
thorough review, it could have been discussed earlier.  Instead, it's
like being nibbled by mice.
