From: Mattia Dongili <malattia@linux.it>
Subject: Re: e100 oops on resume
Date: Sat, 28 Jan 2006 12:53:35 +0100
Message-ID: <20060128115335.GA4511@inferi.kami.home>
References: <20060124225919.GC12566@suse.de> <20060124232142.GB6174@inferi.kami.home> <20060125090240.GA12651@suse.de> <20060125121125.GH5465@suse.de> <4807377b0601251137r7621216byc47b03a3c634557c@mail.gmail.com> <4807377b0601251628k4227dad0ld731f2c25c211b91@mail.gmail.com> <20060126190236.GA12481@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Olaf Kirch <okir@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932322AbWA1LxH@vger.kernel.org>
To: Stefan Seyfried <seife@suse.de>
Content-Disposition: inline
In-Reply-To: <20060126190236.GA12481@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 26, 2006 at 08:02:37PM +0100, Stefan Seyfried wrote:
> On Wed, Jan 25, 2006 at 04:28:48PM -0800, Jesse Brandeburg wrote:
>  
> > Okay I reproduced the issue on 2.6.15.1 (with S1 sleep) and was able
> > to show that my patch that just removes e100_init_hw works okay for
> > me.  Let me know how it goes for you, I think this is a good fix.
> 
> worked for me in the Compaq Armada e500 and reportedly also fixed the
> SONY that originally uncovered it.

confirmed here too. The patch fixes S3 resume on this Sony (GR7/K)
running 2.6.16-rc1-mm3.

0000:02:08.0 Ethernet controller: Intel Corporation 82801CAM (ICH3) PRO/100 VE (LOM) Ethernet Controller (rev 41)
	Subsystem: Sony Corporation Vaio PCG-GR214EP/GR214MP/GR215MP/GR314MP/GR315MP
	Flags: bus master, medium devsel, latency 66, IRQ 9
	Memory at d0204000 (32-bit, non-prefetchable) [size=4K]
	I/O ports at 4000 [size=64]
	Capabilities: <available only to root>

thanks
-- 
mattia
:wq!
