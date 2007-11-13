From: "Giacomo A. Catenazzi" <cate@cateee.net>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 16:24:32 +0100
Message-ID: <4739C1B0.8000803@cateee.net>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Mark Lord <liml@rtr.ca>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <4739AFE0.20705@rtr.ca>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark Lord wrote:
> Ingo Molnar wrote:
> ..
>> This is all QA-101 that _cannot be argued against on a rational 
>> basis_, it's just that these sorts of things have been largely ignored 
>> for years, in favor of the all-too-easy "open source means many 
>> eyeballs and that is our QA" answer, which is a _good_ answer but by 
>> far not the most intelligent answer! Today "many eyeballs" is simply 
>> not good enough and nature (and other OS projects) will route us 
>> around if we dont change.
> ..
> 
> QA-101 and "many eyeballs" are not at all in opposition.
> The latter is how we find out about bugs on uncommon hardware,
> and the former is what we need to track them and overall quality.
> 
> A HUGE problem I have with current "efforts", is that once someone
> reports a bug, the onus seems to be 99% on the *reporter* to find
> the exact line of code or commit.  Ghad what a repressive method.


As a long time kernel tester, I see some problem with the
newer "new development model". In the short merge windows,
after to much time, there are to many patches.
So there are problem to bisect bugs, and to have attention
of developers. My impression is that in a week there are
many more messages in lkml and to much bugs to be
handled in these few days.

I've two proposal:

- better patch quality. I would like that every commit
would compile. So an automatic commit test and public
blames could increase the quality of first commits.
[bisecting with non compilable point it is not a trivial
task]

- a slow down the patch inclusion on the merge windows
(aka: not to much big changes in the first days).
As tester I prefer that some big changes would be
included in a "secondary window" (pre o rc release),
in an other period as the big patch rush.

ciao
	cate
