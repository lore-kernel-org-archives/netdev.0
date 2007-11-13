From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 17:30:19 +0000
Message-ID: <20071113173019.14480202@the-village.bc.nu>
References: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
	<20071113.033946.114918709.davem@davemloft.net>
	<20071113034916.2556edd7.akpm@linux-foundation.org>
	<20071113.035824.40509981.davem@davemloft.net>
	<20071113041259.79c9a8c5.akpm@linux-foundation.org>
	<20071113134029.GA30978@elte.hu>
	<4739AFE0.20705@rtr.ca>
	<40f323d00711130752k19cab8eauc3456721274b3267@mail.gmail.com>
	<20071113171356.GA25824@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Benoit Boissinot <bboissin@gmail.com>, Mark Lord <liml@rtr.ca>,
        Ingo
 Molnar <mingo@elte.hu>,
        Andrew Morton <akpm@linux-foundation.org>,
        David
 Miller <davem@davemloft.net>, protasnb@gmail.com,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
        linux-pcmcia@lists.infradead.org, linux-input@atrey.karlin.mff.cuni.cz,
        bugme-daemon@bugzilla.kernel.org
To: Theodore Tso <tytso@mit.edu>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
In-Reply-To: <20071113171356.GA25824@thunk.org>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org

> The other an automated set of standard pre-built bisection points so
> that testers can more easily localize a bug down to a few hundred
> commits without needing to learn how to use "git bisect" (think Ubuntu
> users).

Before that you want a flowchart or instruction list of boot options to
try. A lot of errors can be localised simply by asking the reported to
boot with things like "iommu=off", "pci=routeirq", "apci=off" etc

That takes a lot less time to run through and can be very informative.

Alan
