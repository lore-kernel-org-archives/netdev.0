From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: [PATCH] tg3: fix big endian MAC address collection failure
Date: Mon, 13 Apr 2009 19:00:15 -0700
Message-ID: <20090414020015.GC11615@xw6200.broadcom.net>
References: <1239661059.9237.4.camel@HP1>
 <1239661934.3278.113.camel@mulgrave.int.hansenpartnership.com>
 <20090414012548.GB11615@xw6200.broadcom.net>
 <20090413.184035.137905532.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"James.Bottomley@HansenPartnership.com"
	<James.Bottomley@HansenPartnership.com>,
	"Michael Chan" <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20090413.184035.137905532.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 13, 2009 at 06:40:35PM -0700, David Miller wrote:
> From: "Matt Carlson" <mcarlson@broadcom.com>
> Date: Mon, 13 Apr 2009 18:25:48 -0700
> 
> > Michael noticed that your NVRAM signature is byteswapped in NVRAM. (!)
> > That also explains why the driver is trying to obtain the MAC address
> > through NVRAM, rather than getting it from shared memory.  The device's
> > bootcode is not working correctly.
> 
> If this problem is pervasive, which it seems it is since we
> have at least two people hitting this problem, we'll need
> to find a way to handle it without saying "update your
> BIOS or system firmware"

Well, Robin's problem looks distinctly different than James'.  I believe
Robin's problem has to do with the legacy EEPROM access routines.  The
patchset may have overlooked something in that area.  I just need to
gather evidence to prove it.

I did run some tests this afternoon on a similar IA64 HP machine and
they ran fine.  Consequently, I'm optimistic that James' problem is local
to his machine.  If this turns out to be a wider problem, then I agree
we'll need to find an appropriate solution.

