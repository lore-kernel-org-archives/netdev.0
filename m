From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [GIT]: Networking
Date: Sun, 13 Dec 2009 14:00:43 -0500
Message-ID: <4B2539DB.5020805@gmail.com>
References: <20091211.181712.211179737.davem@davemloft.net>	<4B236C18.4050007@gmail.com> <20091212022439.fae86037.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753920AbZLMTHI@vger.kernel.org>
In-Reply-To: <20091212022439.fae86037.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Sat, 12 Dec 2009 05:10:32 -0500 William Allen Simpson <william.allen.simpson@gmail.com> wrote:
> 
>> David Miller wrote:
>>> David S. Miller (4):
>>>       Merge branch 'master' of git://git.kernel.org/.../linville/wireless-next-2.6
>>>       tcp: Remove runtime check that can never be true.
>> This is a poor patch that was never sent to the netdev list for review.
> 
> It's better than the original code, which was checking to see whether a
> u8 exceeded 536!
> 
It's preventative, to insure against changes to field sizes.  And it's
correct C in form that has compiled without error for a dozen years.  But
as you pointed out, gcc 4.0 generates a warning, while gcc 4.4 doesn't....

In the olden days, we'd have done these tests with preprocessor code, and
that's apparently the style that Linux still prefers.  Sorry, I've not paid
much attention since early debian, so I'm not up on the current state of
undocumented Linux defines.

As I mentioned in an early post to the netdev list, while I've long had
credit in BSD-derived systems, this is the first I've tried to implement for
Linux kernel -- although I did give permission 15 or so years ago for a fair
amount of my stuff to be ported here under GPL....

Thanks in advance for your patience.


>> Please substitute the better patch in the main tree.
> 
> Linus won't remove a commit from the middle of David's merge and
> replace it with some unchangelogged, un-signed-off alternative.
> 
Actually, it *was* change-logged, discussed, and signed-off:

   http://www.spinics.net/lists/netdev/msg115570.html

David rejected it with the deeply explanatory message:

   "Guess again."

   http://www.spinics.net/lists/netdev/msg115585.html

I'll also remind you that David has previously rejected range-checking in
other patches of mine, with the message:

   "You're being way too anal here, and adding these checks to
   drivers would be just a lot of rediculious bloat." [sic]

So, we have a fundamental difference about checking for negative before
stuffing a signed value into an unsigned value.

Then again, in 30+ years, AFAIK I've never shipped code that had a
serious denial of service attack because of a failure to range check.
Yes, I'm referring to 2.6.29, .30, and .31.

I may not be perfect, but I try really, really hard to get it right.


> An appropriate way to handle this is to prepare a new patch against
> Linus or David's tree after this merge has been performed.  Package
> that patch in the usual way and send it to the usual recipients. That's
> the no-fuss, no-drama, stuff-gets-done path.
> 
It was ready before the merge was performed -- instead we got Miller-lite
drama, fuss, and no-stuff-gets-done....

Since David has rejected it, I was using this message to appeal.

Is there no ability to appeal poor decisions by a maintainer?
