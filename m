From: "Chad N. Tindel" <ctindel@falcon.csc.calpoly.edu>
Subject: Re: [Bonding-devel] Re: Bonding driver unreliable under high CPUload
Date: Tue, 17 Sep 2002 12:58:24 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.44.0209171257180.11147-100000@falcon.csc.calpoly.edu>
References: <3D878841.EB580DE9@digeo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>,
   "Cureington, Tony" <tony.cureington@hp.com>,
   Pascal Brisset <pascal.brisset-ml@wanadoo.fr>,
   <bonding-devel@lists.sourceforge.net>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@digeo.com>
In-Reply-To: <3D878841.EB580DE9@digeo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> > Also, a further question:  do you have access to the slave struct
> > net_device?  If so, just test netif_carrier_ok(slave_dev) and avoid all
> > that ioctl calling if it returns non-zero.
>
> Make that "avoid all that ioctl calling from interrupt context", which
> is a bug.  Of the box-killing variety ;)

Will netif_carrier_ok(slave_dev) always work?  Do all drivers support the
__LINK_STATE_NOCARRIER flag?  If so, is there any reason to call the ioctl
in the first place?

Chad
