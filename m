From: "David S. Miller" <davem@redhat.com>
Subject: Re: Info: NAPI performance at "low" loads
Date: Wed, 18 Sep 2002 13:46:30 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20020918.134630.127509858.davem@redhat.com>
References: <m1hegnky2h.fsf@frodo.biederman.org>
	<20020918.132334.102949210.davem@redhat.com>
	<1032381789.20498.151.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, hadi@cyberus.ca, akpm@digeo.com,
   manfred@colorfullife.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: alan@lxorguk.ukuu.org.uk
In-Reply-To: <1032381789.20498.151.camel@irongate.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Alan Cox <alan@lxorguk.ukuu.org.uk>
   Date: 18 Sep 2002 21:43:09 +0100
   
   The inb timing depends on the PCI bus. If you want proof set a Matrox
   G400 into no pci retry mode, run a large X load at it and time some inbs
   you should be able to get to about 100 milliseconds for an inb to
   execute
   
Matrox isn't using inb/outb instructions to IO space, it is being
accessed by X using MEM space which is done using normal load and
store instructions on x86 after the card is mmap()'d into user space.
