From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: strange network performance degradation 2.6.8-rc3-mm1 -> 2.6.8-rc4-mm1
Date: Sun, 15 Aug 2004 11:59:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040815095900.GA2846@electric-eye.fr.zoreil.com>
References: <20040814060948.GA7842@middle.of.nowhere> <20040814121533.GB18754@electric-eye.fr.zoreil.com> <20040814135606.GA6001@middle.of.nowhere> <20040814150824.GA21843@electric-eye.fr.zoreil.com> <20040814161039.GA1985@middle.of.nowhere> <20040814172835.GA23427@electric-eye.fr.zoreil.com> <20040814190140.GA1954@middle.of.nowhere> <20040814192740.GB23427@electric-eye.fr.zoreil.com> <20040815055455.GA1496@middle.of.nowhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pasi Sjoholm <ptsjohol@cc.jyu.fi>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jurriaan <thunder7@xs4all.nl>
Content-Disposition: inline
In-Reply-To: <20040815055455.GA1496@middle.of.nowhere>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jurriaan <thunder7@xs4all.nl> :
> > > 2.6.8-rc4-mm1 + 8139too-mm-revert + 8139too-10 + 8139too-20: doesn't boot
> > 
> > Thanks. Erm... not exactly what I had expected.
> > 
> > Could you return to 2.6.8-rc4-mm1 + 8139too-mm-revert.patch and try each
> > of the three patches attached ?
> > 
> patch #1 boots
> patch #2 doesn't boot
> patch #3 boots

Ok, the early read of the interrupt status register is the culprit.

I have modified 8139too-10.patch so that it behaves like patch #1 and 
resynced the whole serie.

Can you both apply the updated patches below ?

If M.Sjoholm's setup works fine, I'll forward the update for inclusion
in -mm/-netdev.

http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-mm-revert.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-10.patch
http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.8-rc4-mm1/8139too-20.patch

--
Ueimor
