From: "Teras Timo (EXT-YomiGroup/Helsinki)" <Ext-Timo.Teras@nokia.com>
Subject: Re: [PATCH] Add ability to register class interfaces for network class
Date: Tue, 26 Oct 2004 23:52:39 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026205239.GA23825@two.research.nokia.com>
References: <20041026183526.GA23535@two.research.nokia.com> <20041026184838.GB16621@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ext Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20041026184838.GB16621@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 26, 2004 at 07:48:38PM +0100, ext Christoph Hellwig wrote:
> On Tue, Oct 26, 2004 at 09:35:26PM +0300, Timo Ter=E4s wrote:
> > Add functions to register class interfaces for network class.
> > Similar to the ones found in scsi subsystem.
> >=20
> > Originally posted on linux-net and related discussion can be found
> > from http://marc.theaimsgroup.com/?l=3Dlinux-net&m=3D109758592121767&=
w=3D2.
> >=20
> > Signed-off-by: Timo Ter=E4s <ext-timo.teras@nokia.com>
>=20
> And you still haven't told why this makes sense nor shown a user for it.

Did you read my original reply to your earlier mail?

I pointed out the reason why I need it: to add an attribute:
/sys/class/net/<interface>/<new_attribute>. Others might want to do this
too.

Also the interface subsystem is used in many places (eg. i2o) to create
all the sysfs entries. Maybe it'd be useful to do in net class as well.
And if'd make separate interfaces for standard attributes and wireless
attributes. That way you'd get rid of the #ifdefs of WIRELESS_EXT in
net-sysfs.c.

On the other hand you didn't answer my question: why the
interface registration should not be possible?
Documentation/driver-model/interface.txt states that this is exactly the
thing it should be used for.

Regards,
  Timo
