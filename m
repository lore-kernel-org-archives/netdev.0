From: Jurriaan <thunder7@xs4all.nl>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sun, 15 Aug 2004 12:44:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815104427.GA2157@middle.of.nowhere>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com> <20040814135606.GA6001@middle.of.nowhere> <20040814150824.GA21843@electric-eye.fr.zoreil.com> <20040814161039.GA1985@middle.of.nowhere> <20040814172835.GA23427@electric-eye.fr.zoreil.com> <20040814190140.GA1954@middle.of.nowhere> <20040814192740.GB23427@electric-eye.fr.zoreil.com> <20040815055455.GA1496@middle.of.nowhere> <20040815095900.GA2846@electric-eye.fr.zoreil.com>
Reply-To: Jurriaan <thunder7@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pasi Sjoholm <ptsjohol@cc.jyu.fi>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20040815095900.GA2846@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Sun, Aug 15, 2004 at 11:59:00AM +0200
> 
> Ok, the early read of the interrupt status register is the culprit.
> 
> I have modified 8139too-10.patch so that it behaves like patch #1 and 
> resynced the whole serie.
> 
> Can you both apply the updated patches below ?
> 
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-mm-revert.patch
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-10.patch
> http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-20.patch
> 
2.6.8-rc4-mm1 with those patches applied boots, and the network isn't
slow either.

Thanks,
Jurriaan
-- 
Sort of a pregnant Johnny Cash, actually.
	Rev Hammer describing his voice in Elizabeth's Great Gallop
Debian (Unstable) GNU/Linux 2.6.8 2x6078 bogomips load 0.01
