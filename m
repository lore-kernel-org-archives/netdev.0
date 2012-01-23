From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] r8169: Randomise invalid MAC addresses
Date: Mon, 23 Jan 2012 21:43:18 +0000
Message-ID: <20120123214318.7183775c@pyramind.ukuu.org.uk>
References: <1327343540-30348-1-git-send-email-torne@google.com>
	<CAP=VYLqpUun0FtCs4VWDeLm-mAri=+UV3psRA12eVbV1So_c-Q@mail.gmail.com>
	<CAEV-rjeC1NwbUwdmEEquGf7S8uttsW5hwTjF5nTC_JXY7=OC9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Gortmaker <paul.gortmaker@gmail.com>, nic_swsd@realtek.com,
	romieu@fr.zoreil.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Torne (Richard Coles)" <torne@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEV-rjeC1NwbUwdmEEquGf7S8uttsW5hwTjF5nTC_JXY7=OC9A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So, is this just not going to be acceptable in any form? What about
> refactoring the existing drivers that do this so that this code
> doesn't need to be repeated in every driver, if that would help? I'd
> really quite like to get standard linux distros to be compatible with
> the Joggler, and this is one of the few changes that's actually needed
> (one way or another).

It ought to be about a ten line change in Red Hat/Fedora, you could also
do it generically for most distributions as a udev rule.

Alan
