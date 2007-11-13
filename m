From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 22:20:06 +0100
Message-ID: <20071113212006.GM4250@stusta.de>
References: <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113181228.GF4250@stusta.de> <4739EA83.5040006@rtr.ca> <20071113183605.GG4250@stusta.de> <4739F12E.5020807@rtr.ca> <20071113190428.GH4250@stusta.de> <4739FA4D.1050900@rtr.ca> <20071113200028.GJ4250@stusta.de> <473A057A.90802@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Mark Lord <liml@rtr.ca>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
Content-Disposition: inline
In-Reply-To: <473A057A.90802@rtr.ca>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 03:13:46PM -0500, Mark Lord wrote:
> Adrian Bunk wrote:
>> On Tue, Nov 13, 2007 at 02:26:05PM -0500, Mark Lord wrote:
> ..
>>> If you've been making significant updates to a driver/subsystem,
>>> and people are reporting that it is now broken for them,
>>
>> What are "significant updates"?
>>
>> Sometimes one person makes one small patch and this patch contains
>> a typo.
> ..
>
> Then that person should double check their changes against
> the problems reported, and re-convince themselves that the
> breakage wasn't from those.  Simple. 

Simple?

Everything you have in mind with "should double check their changes" is 
simply not realistic with dozens of known unfixed regressions within 
more than half a million changed or new lines of code written by more 
than 800 people - all numbers only counted since 2.6.23.

>...
>>> The reporters can help,
>>> and many may even git-bisect or send patches.  But you cannot *expect* or 
>>> *insist* upon them doing your job.
>>
>> Bullshit.
>>
>> Bug fixing is not about finding someone to blame, it's about getting the 
>> bug fixed.
> ..
>
> It's not about blame, it's about paying attention to breakages in code that a
> person claims to be supporting, and then doing their best to resolve the issues.

Maintainers are just humans with limited time. 

You were the one who suggested to "distribute code maintainership", 
so you should explain how to find the additional maintainers.

> Again, if one has the time to actively write/modify code such that something breaks,
> then that person should also make time to fix the breakages.

code writer != subsystem maintainer

And git-bisect is the tool that tells you who broke it.

>> The bug reporter is the person who can reproduce the problem, and if it's 
>> a regression then bisecting is the natural way of getting nearer at 
>> getting it fixed.
> ..
> For the third time, no disagreement here.  git-bsect can help in many cases,
> but not in all cases.  And it requires a great time commitment from somebody
> who's system used to work and now doesn't work.  The person who broke it has
> a fair bit of responsibility there, too.

git-bisect can help only for regressions, and it can help for most 
regressions.

And you shouldn't try to make a problem out of something that isn't a 
problem:

Bug submitters are either volunteers who test -rc or even -git or -mm 
kernels for finding bugs or people who want a problem they experience 
fixed.

In both cases the submitters are usually willing to invest some time for 
helping to get the bug fixed.

> cheers

cu
Adrian

--

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
