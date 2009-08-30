From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 NETDEV WATCHDOG: eth0: transmit timed out [0/8]
Date: Sun, 30 Aug 2009 22:26:06 +0200
Message-ID: <20090830202606.GA24479@electric-eye.fr.zoreil.com>
References: <b410963b0908290216x19206aa6o4458bb55b5578a04@mail.gmail.com> <1251553180.13707.16.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roma1390 <roma1390@gmail.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754050AbZH3UV2@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1251553180.13707.16.camel@obelisk.thedillows.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Dillow <dave@thedillows.org> :
> On Sat, 2009-08-29 at 12:16 +0300, roma1390 wrote:
> > Using 3 different r8169 devices on 2 servers (from 2 server so 100% of
> > population) we getting
> > 
> > NETDEV WATCHDOG: eth0: transmit timed out
> 
> You're running an old version of the kernel, and the driver was patched
> to fix that issue in 2.6.30. It is also in the 2.6.29.x stable series,
> and I think maybe the 2.6.28.x series -- please try those and see if you
> problem is resolved.

The fix in 2.6.28.x targets the netdev watchdog problem at boot time only.
2.6.28.x does not include something similar to
f11a377b3f4e897d11f0e8d1fc688667e2f19708 so 2.6.28.x will almost surely
not fit.

-- 
Ueimor
