From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 00:46:20 -0700
Message-ID: <200711140046.20391.vda.linux@googlemail.com>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org> <200711131739.45820.vda.linux@googlemail.com> <20071114072715.GO4250@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Theodore Tso <tytso@mit.edu>,
 Benoit Boissinot <bboissin@gmail.com>,
 Mark Lord <liml@rtr.ca>,
 Ingo Molnar <mingo@elte.hu>,
 Andrew Morton <akpm@linux-foundation.org>,
 David Miller <davem@davemloft.net>,
 protasnb@gmail.com,
 linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 alsa-devel@alsa-project.org,
 linux-ide@vger.kernel.org,
 linux-pcmcia@lists.infradead.org,
 linux-input@atrey.karlin.mff.cuni.cz,
 bugme-daemon@bugzilla.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071114072715.GO4250@stusta.de>
Content-Disposition: inline
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

On Wednesday 14 November 2007 00:27, Adrian Bunk wrote:
> You missed the following in my email:
> "we slowly scare them away due to the many bug reports without any
>  reaction."
>
> The problem is that bug reports take time. If you go away from easy
> things like compile errors then even things like describing what does
> no longer work, ideally producing a scenario where you can reproduce it
> and verifying whether it was present in previous kernels can easily take
> many hours that are spent before the initial bug report.
>
> If the bug report then gets ignored we discourage the person who sent
> the bug report to do any work related to the kernel again.

Cannot agree more. I am in a similar position right now.
My patch to aic7xxx driver was ubmitted four times
with not much reaction from scsi guys.

Finally they replied and asked to rediff it against their
git tree. I did that and sent patches back. No reply since then.

And mind you, the patch is not trying to do anything
complex, it mostly moves code around, removes 'inline',
adds 'const'. What should I think about it?
--
vda
