From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 19:12:28 +0100
Message-ID: <20071113181228.GF4250@stusta.de>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca> <20071113164650.GA28493@elte.hu> <4739E3D0.10201@rtr.ca>
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
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4739E3D0.10201@rtr.ca>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 13, 2007 at 12:50:08PM -0500, Mark Lord wrote:
> Ingo Molnar wrote:
>>
>> for example git-bisect was godsent. I remember that years ago bisection of 
>> a bug was a very laborous task so that it was only used as a final, 
>> last-ditch approach for really nasty bugs. Today we can autonomouly bisect 
>> build bugs via a simple shell command around "git-bisect run", without any 
>> human interaction! This freed up testing resources 
> ..
>
> It's only a godsend for the few people who happen to be kernel developers

It's also godsend for users who want a regression they observe fixed.

If you can tell which patch broke it you often turned a very hard to 
debug problem into a relatively easy fixable problem.

As an example, [1] was an issue a normal user could discover, and 
bisecting made the difference between "nearly undebuggable" and
"easily fixable by revertng a commit".

> and who happen to already use git.

As already said in thread, the required instructions for bisecting are 
relatively short and simple (assuming the user can build his own 
kernels).

> It's a 540MByte download over a slow link for everyone else.

Not everyone has a slow connection.

For me, the speed of cloning a tree from git.kernel.org is completely 
cpu bound and limited by the speed of the 1.8 Ghz Athlon in my 
computer...

But if there is a real life problem like people with extremely slow and 
expensive internet connections not being able to bisect bugs these 
problems should be named and fixed (e.g. by sending CDs).

> -ml

cu
Adrian

[1] http://lkml.org/lkml/2007/11/12/154

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

