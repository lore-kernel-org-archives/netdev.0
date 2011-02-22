From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] rt2x00: Use ops name instead of device name
Date: Tue, 22 Feb 2011 08:44:23 -0500
Message-ID: <1298382263.6140.1196.camel@gandalf.stny.rr.com>
References: <1298380368.6140.1193.camel@gandalf.stny.rr.com>
	 <1298381695.2211.486.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Felix Fietkau <nbd@openwrt.org>,
	Ivo van Doorn <IvDoorn@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>, abogani@texware.it
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1298381695.2211.486.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-02-22 at 13:34 +0000, Ben Hutchings wrote:

> > 19:   73474106          0   IO-APIC-fasteoi   ata_piix, uhci_hcd:usb6, 0000:05:01.0

> >  	rt2x00dev->irq = pci_dev->irq;
> > -	rt2x00dev->name = pci_name(pci_dev);
> > +	rt2x00dev->name = ops->name;


> But then how can users distinguish the IRQs for multiple devices handled
> by the same driver?  (Probably unusual for WLAN devices, but still
> possible.)
> 
> I assume you can't use a net device name as there may be multiple net
> devices per bus device?

Honestly, I do not know this code well enough, but this patch seemed to
solve the problem at hand. Hence I sent it out to the experts hoping
they either take this patch or come up with a proper solution ;)

In any case, just posting the pci address is not a pretty answer.

-- Steve
