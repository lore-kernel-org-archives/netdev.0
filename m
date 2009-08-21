From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: [PATCH 2.6.30-rc4] r8169: avoid losing MSI interrupts
Date: Fri, 21 Aug 2009 23:22:25 +0200
Message-ID: <4A8F1011.7040508@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de>	<1242001754.4093.12.camel@obelisk.thedillows.org>	<200905112248.44868.mb@bu3sch.de> <200905112310.08534.mb@bu3sch.de>	<1242077392.3716.15.camel@lap75545.ornl.gov>	<4A09DC3E.2080807@googlemail.com>	<1242268709.4979.7.camel@obelisk.thedillows.org>	<4A0C6504.8000704@googlemail.com>	<1242328457.32579.12.camel@lap75545.ornl.gov>	<4A0C7443.1010000@googlemail.com>	<1243042174.3580.23.camel@obelisk.thedillows.org> <m1skfkrik2.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Dillow <dave@thedillows.org>, Michael Buesch <mb@bu3sch.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932819AbZHUVW3@vger.kernel.org>
In-Reply-To: <m1skfkrik2.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi!

Eric W. Biederman wrote:

> I have what at first glance looks like a problem caused by this
> patch.  For the last month since upgrading one of my machines from
> 2.6.28 to 2.6.30 it has been becomming inaccessible from the
> network and I have a few:
> 
> NETDEV WATCHDOG: eth0 (r8169): transmit timed out
>
> in my logs and a lot soft lockups that always have rtl8169_interrupt
> as the thing that is running.   I suspect your patch has introduced
> a near infinite loop in the interrupt handler and is causing these
> soft lockups.

I've been running 2.6.30 for more than two months now and all is fine.
But this might be a different chip.

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
