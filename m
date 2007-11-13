From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 20:04:28 +0100
Message-ID: <20071113190428.GH4250@stusta.de>
References: <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113181228.GF4250@stusta.de> <4739EA83.5040006@rtr.ca> <20071113183605.GG4250@stusta.de> <4739F12E.5020807@rtr.ca>
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
In-Reply-To: <4739F12E.5020807@rtr.ca>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 01:47:10PM -0500, Mark Lord wrote:
> Adrian Bunk wrote:
> ...
>> I did bisecting myself, and I know that it costs time and work.
>>
>> But the first point is the above one that it makes otherwise nearly 
>> undebuggable problems debuggable and fixable.
> ..
>
> Definitely useful, no question.
>
> But the problem is now that kernel devs are addicted to it,
> many won't even consider resolving a problem any other way.
>
> That's not "maintaining" (or supporting) one's code.

What you replaced with two dots contained the answer to this:

Another point is that it shifts the work from the few experienced 
developers to the many users. Users (and voluntary testers) we have
many, but developer time for debugging bug reports is a quite scarce 
resource.

> And when a "maintainer" is too busy to find/fix their own bugs,
> that could be a sign that they've bitten off too big of a chunk
> of the kernel, and it's time for them to distribute code maintainership.

The problem is: Maintainers don't grow on trees.

You need people who are both technically capable and willing to spend 
time on the non-sexy task of debugging problems.

Where do you plan to find them?

If you don't believe me, please find a maintainer for the currently 
unmaintained parallel port support.

Or if you want a harder task, find a maintainer for the floppy driver...

> Cheers

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
