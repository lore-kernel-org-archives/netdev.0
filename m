From: jamal <hadi@cyberus.ca>
Subject: Re: 3c59x 2.4.18 userspace seeing UDP packets with bad checksum?
Date: Tue, 30 Jul 2002 09:40:45 -0400 (EDT)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0207300933350.15727-100000@shell.cyberus.ca>
References: <200207301331.RAA03211@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: bert hubert <ahu@ds9a.nl>, <netdev@oss.sgi.com>, <akpm@zip.com.au>,
   <jgarzik@mandrakesoft.com>, <becker@scyld.com>
Return-path: <owner-netdev@oss.sgi.com>
To: <kuznet@ms2.inr.ac.ru>
In-Reply-To: <200207301331.RAA03211@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org




On Tue, 30 Jul 2002 kuznet@ms2.inr.ac.ru wrote:

> Hello!
>
> > Regarding Andi's message, isn't it so that recvfrom() may return but in that
> > case returns -1 and sets errno to EAGAIN?
>
> It should if we calculated this checksum. But 3com pretends to do this
> in hardware. :-)
>
>

It doesnt seem like the NIC is Kaput given that he only sees the problems
with the Taiwanese site (unless everyone else sends no checksums). More
like what is in the data these guys send that is acivating this stuff?
Certainly that will become more obvious when
he comments out CHECKSUM_UNNECESSARY in the driver.

BTW, It would be nice if the driver also reported checksum errors. This
seems to only report checksum hits right now on close();
Is this something we need to add into generic stats? It would also
be nice to see breakdown by TCP and UDP. A NIC/driver that doesnt
implement that feature doesnt display those parameters.

cheers,
jamal
