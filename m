From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Info: NAPI performance at "low" loads
Date: 19 Sep 2002 16:53:02 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1032450782.27721.5.camel@irongate.swansea.linux.org.uk>
References: <1032381789.20498.151.camel@irongate.swansea.linux.org.uk>
	<20020918.134630.127509858.davem@redhat.com>
	<1032383727.20463.155.camel@irongate.swansea.linux.org.uk>
	<20020918.142250.130847722.davem@redhat.com>
	<m18z1ykoms.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca, akpm@digeo.com,
   manfred@colorfullife.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m18z1ykoms.fsf@frodo.biederman.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2002-09-19 at 16:03, Eric W. Biederman wrote:
> If I do an inb to a PCI-X device running at 133Mhz it should come back
> much faster than an inb from my serial port on the ISA port.  What
> is the reason for the fixed minimum timing?

As far as I can tell the minimum time for the inb/outb is simply the
time it takes the bus to respond. The only difference there is that for
writel rather than outl you won't wait for the write to complete on the
PCI bus just dump it into the fifo if its empty
