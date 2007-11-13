From: Mark Lord <liml@rtr.ca>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 09:08:32 -0500
Message-ID: <4739AFE0.20705@rtr.ca>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113134029.GA30978@elte.hu>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

Ingo Molnar wrote:
..
> This is all QA-101 that _cannot be argued against on a rational basis_, 
> it's just that these sorts of things have been largely ignored for 
> years, in favor of the all-too-easy "open source means many eyeballs and 
> that is our QA" answer, which is a _good_ answer but by far not the most 
> intelligent answer! Today "many eyeballs" is simply not good enough and 
> nature (and other OS projects) will route us around if we dont change.
..

QA-101 and "many eyeballs" are not at all in opposition.
The latter is how we find out about bugs on uncommon hardware,
and the former is what we need to track them and overall quality.

A HUGE problem I have with current "efforts", is that once someone
reports a bug, the onus seems to be 99% on the *reporter* to find
the exact line of code or commit.  Ghad what a repressive method.

And if the "developer" who broke the damn thing, or who at least
"claims" to be supporting that code, cannot "reproduce" the bug,
they drop it completely.

Contrast that flawed approach with how Linus does things..
he thinks through the symptoms, matches them to the code,
and figures out what the few possibilities might be,
and feeds back some trial balloon patches for the bug reporter to try.

MUCH better. 

Linus also asks for a git bisect, but doesn't insist upon the reporter
learning an entire new (poorly documented) toolset just to to report a bug.

Blah!

And remember, *I'm* an old-time Linux kernel developer.. just think about
the people reporting bugs who haven't been around here since 1992..

-ml
