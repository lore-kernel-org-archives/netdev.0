From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Info: NAPI performance at "low" loads
Date: 18 Sep 2002 21:43:09 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1032381789.20498.151.camel@irongate.swansea.linux.org.uk>
References: <Pine.GSO.4.30.0209172053360.3686-100000@shell.cyberus.ca>
	<20020917.180014.07882539.davem@redhat.com>
	<m1hegnky2h.fsf@frodo.biederman.org>
	<20020918.132334.102949210.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, hadi@cyberus.ca, akpm@digeo.com,
   manfred@colorfullife.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20020918.132334.102949210.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2002-09-18 at 21:23, David S. Miller wrote:
> The x86 processor has a well defined timing for executing inb
> etc. instructions, the timing is fixed and is independant of the
> speed of the PCI bus the device is on.

Earth calling Dave Miller

The inb timing depends on the PCI bus. If you want proof set a Matrox
G400 into no pci retry mode, run a large X load at it and time some inbs
you should be able to get to about 100 milliseconds for an inb to
execute
