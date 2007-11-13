From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 15:13:46 -0500
Message-ID: <473A057A.90802@rtr.ca>
References: <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113181228.GF4250@stusta.de> <4739EA83.5040006@rtr.ca> <20071113183605.GG4250@stusta.de> <4739F12E.5020807@rtr.ca> <20071113190428.GH4250@stusta.de> <4739FA4D.1050900@rtr.ca> <20071113200028.GJ4250@stusta.de>
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
To: Adrian Bunk <bunk@kernel.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20071113200028.GJ4250@stusta.de>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Tue, Nov 13, 2007 at 02:26:05PM -0500, Mark Lord wrote:
..
>> If you've been making significant updates to a driver/subsystem,
>> and people are reporting that it is now broken for them,
> 
> What are "significant updates"?
> 
> Sometimes one person makes one small patch and this patch contains
> a typo.
..

Then that person should double check their changes against
the problems reported, and re-convince themselves that the
breakage wasn't from those.  Simple. 

>> then it's your job to make it right.
> 
> We have some open drivers/ata/ regressions.
..

Yup, but they're more specific than just that entire subsystem,
and the maintainers are actively pursuing the problems.
Exactly what should be happening.

> I see some person named "Mark Lord" being responsible for 4 commits.
> 
> What pubishment do you plan for him if 2.6.24 ships with any libata 
> regressions?
..

If the code I'm touching breaks, then I'll fix it ASAP,
exactly what the users of that code might expect.

>> The reporters can help,
>> and many may even git-bisect or send patches.  
>> But you cannot *expect* or *insist* upon them doing your job.
> 
> Bullshit.
> 
> Bug fixing is not about finding someone to blame, it's about getting the 
> bug fixed.
..

It's not about blame, it's about paying attention to breakages in code that a
person claims to be supporting, and then doing their best to resolve the issues.

Again, if one has the time to actively write/modify code such that something breaks,
then that person should also make time to fix the breakages.

> The bug reporter is the person who can reproduce the problem, and if 
> it's a regression then bisecting is the natural way of getting nearer 
> at getting it fixed.
..
For the third time, no disagreement here.  git-bsect can help in many cases,
but not in all cases.  And it requires a great time commitment from somebody
who's system used to work and now doesn't work.  The person who broke it has
a fair bit of responsibility there, too.

cheers
