From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Tue, 24 Jan 2012 18:15:46 +0100
Message-ID: <20120124171546.GA32184@atrey.karlin.mff.cuni.cz>
References: <1327343540-30348-1-git-send-email-torne@google.com>
 <20120123212914.747c852f@pyramind.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Torne (Richard Coles)" <torne@google.com>, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120123212914.747c852f@pyramind.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

> > If the default MAC address stored in the card is invalid, replace it
> > with a random address and complain about it.
> 
> See the discussion about the pch ethernet card. Detect the error and warn
> about it, block opening it and let the user set it with ifconfig xx hw
> aa:bb:cc:dd:ee:ff

Kernel should provide hw abstraction, and that should mean doing
something about commonly-bad ethernet cards.

Userspace does not quite cut it, think about nfsroot for example.

									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
