From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH v2 15/19] kvm: add dynamic IRQ support
Date: Mon, 13 Apr 2009 13:44:30 -0400
Message-ID: <49E379FE.8060202@novell.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163200.32740.90490.stgit@dev.haskins.net> <49E0CCDB.4000806@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49E0CCDB.4000806@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Avi Kivity wrote:
>>  
>
> Given that you're using the apic to inject the IRQ, you'll need an
> EOI.  So what's the difference between dynirq and MSI, performance wise?
>

I would have loved to eliminate that EOI completely, but that is a much
broader problem to solve ;)

Actually dynirq wasnt introduced as a performance alternative over MSI. 
Rather, I was trying to eliminate the complexity of needing to sync
between the userspace PCI emulation and the in kernel models.

However, its moot.  Since v2 introduce virtio-vbus, I now have a much
clearer picture of what is needed here, and v3 will simply integrate
with MSI interrupts and drop dynirq completely.  So please ignore this
patch.

-Greg


