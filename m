From: "Benoit Boissinot" <bboissin@gmail.com>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 16:52:32 +0100
Message-ID: <40f323d00711130752k19cab8eauc3456721274b3267@mail.gmail.com>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	 <20071113.033946.114918709.davem@davemloft.net>
	 <20071113034916.2556edd7.akpm@linux-foundation.org>
	 <20071113.035824.40509981.davem@davemloft.net>
	 <20071113041259.79c9a8c5.akpm@linux-foundation.org>
	 <20071113134029.GA30978@elte.hu> <4739AFE0.20705@rtr.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Ingo Molnar" <mingo@elte.hu>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"David Miller" <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: "Mark Lord" <liml@rtr.ca>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <4739AFE0.20705@rtr.ca>
Content-Disposition: inline
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov 13, 2007 3:08 PM, Mark Lord <liml@rtr.ca> wrote:
>
> Ingo Molnar wrote:
> ..
> > This is all QA-101 that _cannot be argued against on a rational basis_,
> > it's just that these sorts of things have been largely ignored for
> > years, in favor of the all-too-easy "open source means many eyeballs and
> > that is our QA" answer, which is a _good_ answer but by far not the most
> > intelligent answer! Today "many eyeballs" is simply not good enough and
> > nature (and other OS projects) will route us around if we dont change.
> ..
>
> QA-101 and "many eyeballs" are not at all in opposition.
> The latter is how we find out about bugs on uncommon hardware,
> and the former is what we need to track them and overall quality.
>
> A HUGE problem I have with current "efforts", is that once someone
> reports a bug, the onus seems to be 99% on the *reporter* to find
> the exact line of code or commit.  Ghad what a repressive method.
>

Btw, I used to test every -mm kernel. But since I've switched distros
(gentoo->ubuntu)
and I have less time, I feel it's harder to test -rc or -mm kernels (I
know this isn't a lkml problem
but more a distro problem, but I would love having an ubuntu blessed
repo with current dev kernel
for the latest stable ubuntu release).

For debugging, maybe it's time someone does an amazon ec2+s3 service
to automate the bisecting
and create .deb/.rpm from git, I don't know how much it would cost though.

regards,

Benoit
