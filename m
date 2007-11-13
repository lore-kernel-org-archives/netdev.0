From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 14:26:05 -0500
Message-ID: <4739FA4D.1050900@rtr.ca>
References: <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca> <20071113181228.GF4250@stusta.de> <4739EA83.5040006@rtr.ca> <20071113183605.GG4250@stusta.de> <4739F12E.5020807@rtr.ca> <20071113190428.GH4250@stusta.de>
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
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113190428.GH4250@stusta.de>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Tue, Nov 13, 2007 at 01:47:10PM -0500, Mark Lord wrote:
>> Adrian Bunk wrote:
..
> Another point is that it shifts the work from the few experienced 
> developers to the many users. Users (and voluntary testers) we have
> many, but developer time for debugging bug reports is a quite scarce 
> resource.
> 
>> And when a "maintainer" is too busy to find/fix their own bugs,
>> that could be a sign that they've bitten off too big of a chunk
>> of the kernel, and it's time for them to distribute code maintainership.
> 
> The problem is: Maintainers don't grow on trees.
..

Hey, if somebody has time to break things, then they damn well ought
to be able to make time to fix them again.  And the best developers
here on LKML do just that (fix what they break).

You broke it, you fix it.  A simple rule.

Translation for the particularly daft:

If you've been making significant updates to a driver/subsystem,
and people are reporting that it is now broken for them,
then it's your job to make it right.  The reporters can help,
and many may even git-bisect or send patches.  

But you cannot *expect* or *insist* upon them doing your job.
