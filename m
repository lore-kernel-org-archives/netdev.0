From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: 82557/8/9 Ethernet Pro 100 interrupt mitigation support
Date: Tue, 04 Sep 2007 08:56:04 -0700
Message-ID: <46DD8014.7000408@intel.com>
References: <46DBE2E7.7070906@mediatvcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: Marc Sigler <marc.sigler@mediatvcom.com>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <46DBE2E7.7070906@mediatvcom.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marc Sigler wrote:
> Hello everyone,
> 
> I have several systems with three integrated Intel 82559 (I *think*).
> 
> Does someone know if these boards support hardware interrupt mitigation? 
> I.e. is it possible to configure them to raise an IRQ only if their 
> hardware buffer is full OR if some given time (say 1 ms) has passed and 
> packets are available in their hardware buffer.
> 
> I've been using the eepro100 driver up to now, but I'm about to try the 
> e100 driver. Would I have to use NAPI? Or is this an orthogonal feature?

the software developers manual for this part is available on our e1000.sf.net 
page here:
 
http://downloads.sourceforge.net/e1000/OpenSDM_55x_10c.pdf?modtime=1040083200&big_mirror=0

e100 hardware (as far as I can see from the specs) doesn't support any irq 
mitigation, so you'll need to run in NAPI mode if you want to throttle irq's. 
the in-kernel e100 already runs in NAPI mode, so that's already covered.

beware that the eepro100 driver is scheduled for removal (2.6.25 or so).

Cheers,

Auke
