From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Info: NAPI performance at "low" loads
Date: 19 Sep 2002 09:03:39 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m18z1ykoms.fsf@frodo.biederman.org>
References: <1032381789.20498.151.camel@irongate.swansea.linux.org.uk>
	<20020918.134630.127509858.davem@redhat.com>
	<1032383727.20463.155.camel@irongate.swansea.linux.org.uk>
	<20020918.142250.130847722.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, ebiederm@xmission.com, hadi@cyberus.ca,
   akpm@digeo.com, manfred@colorfullife.com, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020918.142250.130847722.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@redhat.com> writes:

>    From: Alan Cox <alan@lxorguk.ukuu.org.uk>
>    Date: 18 Sep 2002 22:15:27 +0100
>    
>    It doesnt matter what XFree86 is doing. Thats just to load the PCI bus
>    and jam it up to prove the point. It'll change your inb timing
>    
> Understood.  Maybe a more accurate wording would be "a fixed minimum
> timing".

Why?

If I do an inb to a PCI-X device running at 133Mhz it should come back
much faster than an inb from my serial port on the ISA port.  What
is the reason for the fixed minimum timing?

Alan asserted there is a posting behavior difference, but that should
not affect reads.

What is different between mmio and pio to a pci device when doing reads
that should make mmio faster?

Eric
