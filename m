From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: RCU stall in af_unix.c, should use spin_lock_irqsave?
Date: Tue, 21 Oct 2014 12:13:04 +0200
Message-ID: <20141021121304.076d5acd@free-electrons.com>
References: <20141021100313.397f4962@free-electrons.com>
	<1413886132.32553.14.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Alexandre FOURNIER <alexandre.fournier@wisp-e.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413886132.32553.14.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Hannes Frederic Sowa,

On Tue, 21 Oct 2014 12:08:52 +0200, Hannes Frederic Sowa wrote:
> On Di, 2014-10-21 at 10:03 +0200, Thomas Petazzoni wrote:
> > So, the question is: is this patch the correct solution (but then other
> > usage of spin_lock in af_unix.c might also need fixing) ? Or is the
> > network driver at fault?
> 
> It feels like a false positive. Do you see one core spinning tightly on
> a lock? Does the system get unusable?

Interrupts are still enabled (for example, sysrq are still working),
but scheduling no longer takes place (all processes are blocked).

Best regards,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
