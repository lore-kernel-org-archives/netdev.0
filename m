From: =?ISO-8859-1?Q?Malte_Schr=F6der?= <MalteSch@gmx.de>
Subject: Re: [PATCH] WOL for sis900
Date: Sun, 31 Oct 2004 14:08:08 +0100
Message-ID: <4184E3B8.2030400@gmx.de>
References: <4183B6B0.7010906@gmx.de> <4183BDB3.8000302@pobox.com> <20041030185959.GA7088@renditai.milesteg.arr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCF698CBEB1F5492250D043A6"
Content-Transfer-Encoding: 8bit
Cc: NetDev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Venzano <webvenza@libero.it>
In-Reply-To: <20041030185959.GA7088@renditai.milesteg.arr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCF698CBEB1F5492250D043A6
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit

Daniele Venzano wrote:
> On Sat, Oct 30, 2004 at 12:13:39PM -0400, Jeff Garzik wrote:
> 
>>Malte Schröder wrote:
>>
>>>Hello,
>>>I have applied the patch from http://lkml.org/lkml/2003/7/16/88 manually 
>>>to 2.6.7 (also works on 2.6.{8,9}) and have been using it since then.
>>>Attached is a diff against 2.6.9.
>>
>>2) Please use ethtool to enable/disable WOL.  No need for a module option.
> 
> 
> Attached is a first try at this wol via ethtool thing. I don't think to
> have got it right, but here it is.
> 
> I tried to test WoL on my laptop, obvioulsy it didn't work, but I don't
> even know if I have the hardware support for it.
> On this page:
> http://www.sis.com/products/connectivity/900.htm
> it says that the magic packet feature is optional.
> 
> I would really like to have some way to check if WoL is supported by the
> hardware before thinking to include this. I didn't find any
> documentation of some use for this.
> 
> Finally, I have never realized the sorry state of sis900 wrt ethtool,
> I'll try to get some more support...
> 
> The attached patch is against clean 2.6.9 and is NOT for inclusion.

I just tried your patch and it works for me :)
My sis900 is on-board component of the sis746 chipset.
-- 
---------------------------------------
Malte Schröder
MalteSch@gmx.de
ICQ# 68121508
---------------------------------------


--------------enigCF698CBEB1F5492250D043A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBhOO74q3E2oMjYtURAsPUAKCSgD/OGm+q3dl9W0lmcnWdj04JoACfcED8
V3eSoQgUIveqDwHwjtGfLlE=
=O+a2
-----END PGP SIGNATURE-----

--------------enigCF698CBEB1F5492250D043A6--
