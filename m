From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 19:36:05 +0100
Message-ID: <20071113183605.GG4250@stusta.de>
References: <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113181228.GF4250@stusta.de> <4739EA83.5040006@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Mark Lord <liml@rtr.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:56563 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751896AbXKMSg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 13:36:28 -0500
Content-Disposition: inline
In-Reply-To: <4739EA83.5040006@rtr.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 01:18:43PM -0500, Mark Lord wrote:
> Adrian Bunk wrote:
>> On Tue, Nov 13, 2007 at 12:50:08PM -0500, Mark Lord wrote:
>>> Ingo Molnar wrote:
>>>> for example git-bisect was godsent. I remember that years ago bisection 
>>>> of a bug was a very laborous task so that it was only used as a final, 
>>>> last-ditch approach for really nasty bugs. Today we can autonomouly 
>>>> bisect build bugs via a simple shell command around "git-bisect run", 
>>>> without any human interaction! This freed up testing resources 
>>> ..
>>>
>>> It's only a godsend for the few people who happen to be kernel developers
>>
>> It's also godsend for users who want a regression they observe fixed.
>>
>> If you can tell which patch broke it you often turned a very hard to debug 
>> problem into a relatively easy fixable problem.
> ..
>
> Oh yes, definitely.  When that use happens to be a kernel dev + git user,
> it saves the *fool who broke it* a hell of a lot of time, because they can
> slough it off onto the poor bloke who notices it.

"fool who broke it" are hard works. Bugs are part of software 
development, so you'd have to name everyone who develops software
a fool.

But the main point is that often you don't know who broke it until you 
know which commit broke it.

> Mind you, no arguing that this is effective when that poor bloke
> has a day free to download the git-tree and build/reboot a dozen times.

I did bisecting myself, and I know that it costs time and work.

But the first point is the above one that it makes otherwise nearly 
undebuggable problems debuggable and fixable.

Another point is that it shifts the work from the few experienced 
developers to the many users. Users (and voluntary testers) we have
many, but developer time for debugging bug reports is a quite scarce 
resource.

And why "poor bloke"? Bisecting takes time, but that's not different 
from e.g. writing code or cleaning up code or going through bug reports.

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

