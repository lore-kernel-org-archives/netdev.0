From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: 17 Jan 2005 19:49:45 -0500
Message-ID: <1106009385.1046.49.camel@jzny.localdomain>
References: <20050116115431.GA13617@lst.de> <20050117225946.GA11845@lst.de>
	 <1106003481.1035.35.camel@jzny.localdomain>
	 <200501180037.58453.christian@borntraeger.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Christoph Hellwig <hch@lst.de>, "David S. Miller" <davem@davemloft.net>,
        pavlic@de.ibm.com, waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Christian =?ISO-8859-1?Q?Borntr=E4ger?= <christian@borntraeger.net>
In-Reply-To: <200501180037.58453.christian@borntraeger.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2005-01-17 at 18:37, Christian Borntr=E4ger wrote:

> I am trying a small simplification here:
> Each physical network adapter offers hundreds of device addresses. You =
need=20
> 3 of them to have one logical network adapter(read,write,data).

the "card" concept is what you call network adapter, correct?
I take it that read and write are control channels and data is where the
skb comes through?
=20
>  S/390 has=20
> hardware supported virtualization. Therefore can then use the hyperviso=
r=20
> (LPAR or z/VM) to give specific LPARs or VM guests exactly 3 device=20
> addresses out of these hundreds.

Can you provision multiple of these cards per VM? if yes, is there some
ID that will break it down to OSInstance:cardid?

> The qeth driver has to register the IP address at the logical network c=
ard=20
> (using 3 device addresses) Afterwards the physical network card knows w=
hich=20
> packet belongs to which device numbers.

I think i understood  but confused: before you attach IP address though,
you cant receive packets? Is there a concept of MAC address which you
can pass to the hypervisor or can you run in promiscmous mode?

Another question: When that driver runs for the physical card - it runs
in the context of a specific VM, correct? In other words it would be
impossible to see the "card" of another instance?=20

cheers,
jamal
