From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: Info: NAPI performance at "low" loads
Date: 18 Sep 2002 18:50:53 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1032371453.20463.139.camel@irongate.swansea.linux.org.uk>
References: <3D87A59C.410FFE3E@digeo.com>
	<Pine.GSO.4.30.0209172053360.3686-100000@shell.cyberus.ca>
	<20020917.180014.07882539.davem@redhat.com>
	<m1hegnky2h.fsf@frodo.biederman.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, hadi@cyberus.ca, akpm@digeo.com,
   manfred@colorfullife.com, netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m1hegnky2h.fsf@frodo.biederman.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2002-09-18 at 18:27, Eric W. Biederman wrote:
> Plus I have played with calibrating the TSC with outb to port
> 0x80 and there was enough variation that it was unuseable.  On some
> newer systems it would take twice as long as on some older ones.

port 0x80 isnt going to PCI space.

x86 generally posts mmio write but not io write. Thats quite measurable.
