From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: de2104x: interrupts before interrupt handler is registered
Date: Mon, 6 Mar 2006 19:59:53 +0000
Message-ID: <20060306195953.GB10703@deprecation.cyrius.com>
References: <20060305180757.GA22121@deprecation.cyrius.com> <20060305185948.GA24765@electric-eye.fr.zoreil.com> <20060306143512.GI23669@deprecation.cyrius.com> <20060306191706.GA6947@deprecation.cyrius.com> <20060306194821.GA15728@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752420AbWCFUAZ@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
In-Reply-To: <20060306194821.GA15728@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Francois Romieu <romieu@fr.zoreil.com> [2006-03-06 20:48]:
> > There's another interrupt related bug in the driver, though.  I
> > sometimes get a kernel panic when rsycing several 100 megs of data
> > across the LAN.  A picture showing the call trace can be found at
> > http://www.cyrius.com/tmp/de2104x_panic.jpg
> Can you publish the .config ?

http://www.cyrius.com/tmp/config-2.6.16-rc5-486

By the way, I'm getting the following messages in dmesg:

eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb00a
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb00a
eth0: tx err, status 0x7fffb00a
eth0: tx err, status 0x7fffb00a
eth0: tx err, status 0x7fffb002
eth0: tx err, status 0x7fffb032
eth0: tx err, status 0x7fffb002

-- 
Martin Michlmayr
http://www.cyrius.com/
