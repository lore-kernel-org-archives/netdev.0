From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Tue, 24 Jan 2012 18:47:33 +0000
Message-ID: <1327430853.2568.4.camel@bwh-desktop>
References: <1327343540-30348-1-git-send-email-torne@google.com>
	 <20120123212914.747c852f@pyramind.ukuu.org.uk>
	 <20120124171546.GA32184@atrey.karlin.mff.cuni.cz>
	 <20120124182826.GA24128@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pavel Machek <pavel@ucw.cz>, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	"Torne (Richard Coles)" <torne@google.com>, <nic_swsd@realtek.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120124182826.GA24128@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-01-24 at 19:28 +0100, Francois Romieu wrote:
> Pavel Machek <pavel@ucw.cz> :
> [...]
> > Kernel should provide hw abstraction, and that should mean doing
> > something about commonly-bad ethernet cards.
> 
> Ask for a refund ?
[...]

This is mostly being done in embedded systems where the system
developers control both the kernel and all of userspace and can easily
bodge things in the userland init process.

Then some adventurous users want to run custom kernels on those systems
and have a reasonable way to deal with that.  The original system worked
and they cannot replace just the network interface, so it is no good
asking for a refund.

None of the push-back from netdev is going to have any effect on the
embedded system developers who are failing to program MAC addresses
properly; it's only going to hurt those adventurous users.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
