From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [GIT] Networking
Date: Sat, 8 Jan 2011 01:09:01 +0100
Message-ID: <20110108000901.GA2133@electric-eye.fr.zoreil.com>
References: <20110106.122003.233698077.davem@davemloft.net> <AANLkTi=7=_FyVsjA3vKEpg8RwfC=m-8QGfqa6ctxQday@mail.gmail.com> <20110107190656.GQ3702@decadent.org.uk> <AANLkTikwrHoOY4wvUp1qn-OT=EjZesSNR29US1ERc0o2@mail.gmail.com> <20110107215505.GA1892@electric-eye.fr.zoreil.com> <AANLkTinANp+Jp8TPKzii6iZLUFpMyrXhmxYr42nZrXQU@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <benh@debian.org>,
	David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>,
	David Woodhouse <dwmw2@infradead.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <AANLkTinANp+Jp8TPKzii6iZLUFpMyrXhmxYr42nZrXQU@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds <torvalds@linux-foundation.org> :
[...]
> Hmm. I never even waited for 60 seconds. Maybe my boot would have
> continued after the delay.

The 60 seconds delay is here :

drivers/base/firmware_class.c
[...]
static int loading_timeout = 60;        /* In seconds */

It can be read and set through sysfs.

I'll give a try at moving the request-firmware dependent stuff to
device-open time in drivers/net/r8169.c tomorrow morning. It's friday.

-- 
Ueimor
