From: Lars Marowsky-Bree <lmb@suse.de>
Subject: Re: The ultimate TOE design
Date: Thu, 16 Sep 2004 11:03:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040916090328.GO26852@marowsky-bree.de>
References: <4148991B.9050200@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Content-Disposition: inline
In-Reply-To: <4148991B.9050200@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 2004-09-15T15:33:47,
   Jeff Garzik <jgarzik@pobox.com> said:

> Then, your host system OS will communicate with the Linux kernel runnin=
g=20
> on the card across the PCI bus, using IP packets (64K fixed MTU).
>=20
> This effectively:

Actually, given that there's almost no reason to offload TCP/IP
processing for speed (better spent the money on CPU / memory for the
main system), I like the idea of this for security: Off-load the packet
filtering to create an additional security barrier. (Different CPU
architecture and all that.)

(With two cards, one could even use the conntrack fail-over internally.
- A Linux-running NIC with builtin firewalling, sell to all the windows
weenies... ;)

With dedicated processors, maybe a IP/Sec accelerator would also be
cool, but I'd think a crypto accelerator for the main system would again
be saner here (unless, of course, the argument of the security domain
isolation is applied again).

Admittedely, one can solve all these differently, but it still might be
cool. ;-)


Sincerely,
    Lars Marowsky-Br=E9e <lmb@suse.de>

--=20
High Availability & Clustering
SUSE Labs, Research and Development
SUSE LINUX AG - A Novell company
