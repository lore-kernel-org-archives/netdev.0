From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <ext-timo.teras@nokia.com>
Subject: Re: [PATCH] Add ability to register class interfaces for network
 class
Date: Wed, 27 Oct 2004 14:31:04 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417F86F8.6020004@nokia.com>
References: <20041026183526.GA23535@two.research.nokia.com> <20041026184838.GB16621@infradead.org> <20041026205239.GA23825@two.research.nokia.com> <20041027111317.GA27240@infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigF26ACBB8F9D29D435ABCCE2D"
Cc: davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ext ext Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20041027111317.GA27240@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF26ACBB8F9D29D435ABCCE2D
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

ext ext Christoph Hellwig wrote:
>>I pointed out the reason why I need it: to add an attribute:
>>/sys/class/net/<interface>/<new_attribute>. Others might want to do this
>>too.
>>
>>Also the interface subsystem is used in many places (eg. i2o) to create
>>all the sysfs entries. Maybe it'd be useful to do in net class as well.
>>And if'd make separate interfaces for standard attributes and wireless
>>attributes. That way you'd get rid of the #ifdefs of WIRELESS_EXT in
>>net-sysfs.c.
>>
>>On the other hand you didn't answer my question: why the
>>interface registration should not be possible?
>>Documentation/driver-model/interface.txt states that this is exactly the
>>thing it should be used for.
> 
> Because we don't add interfaces for the sake of it. You still haven't show
> the user that wants this.  i you presented a sane user the review would be
> quite different.

I am the user wanting it :)

If you want to look more detailed what I'm trying to accomplish you could check:
http://seclists.org/lists/linux-kernel/2004/Oct/1373.html
http://seclists.org/lists/linux-kernel/2004/Sep/8685.html
http://lists.netfilter.org/pipermail/netfilter-devel/2004-August/016342.html

Of course the ideal way to do this would be adding a timer to net_device and 
modifying net-sysfs.c. But I don't think that is going to happen so I want to 
do as unintrusive implementation as possible. And currently I think it'd be 
adding an interface to network class device which creates the related attribute.

Cheers,
   Timo

--------------enigF26ACBB8F9D29D435ABCCE2D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBf4b7FlRU9HaAsIcRAi+eAJ9nAvogeAtnzf2cZQvkG9jMQrOr4gCgj0Mj
byuParE9unKFM1DAr7HJTxs=
=KsDp
-----END PGP SIGNATURE-----

--------------enigF26ACBB8F9D29D435ABCCE2D--
