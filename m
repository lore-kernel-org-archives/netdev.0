From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Info: NAPI performance at "low" loads
Date: 19 Sep 2002 08:58:49 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m1d6rakouu.fsf@frodo.biederman.org>
References: <3D87A59C.410FFE3E@digeo.com>
	<Pine.GSO.4.30.0209172053360.3686-100000@shell.cyberus.ca>
	<20020917.180014.07882539.davem@redhat.com>
	<m1hegnky2h.fsf@frodo.biederman.org>
	<1032371453.20463.139.camel@irongate.swansea.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca, akpm@digeo.com,
   manfred@colorfullife.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1032371453.20463.139.camel@irongate.swansea.linux.org.uk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> writes:

> On Wed, 2002-09-18 at 18:27, Eric W. Biederman wrote:
> > Plus I have played with calibrating the TSC with outb to port
> > 0x80 and there was enough variation that it was unuseable.  On some
> > newer systems it would take twice as long as on some older ones.
> 
> port 0x80 isnt going to PCI space.

Agreed.  It isn't going anywhere, and it takes it a while to recogonize
that.
 
> x86 generally posts mmio write but not io write. Thats quite measurable.

The difference timing difference between posted and non-posted writes
I can see.

Eric
