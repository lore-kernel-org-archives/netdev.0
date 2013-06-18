From: Tomi Valkeinen <tomi.valkeinen@ti.com>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Tue, 18 Jun 2013 11:35:16 +0300
Message-ID: <51C01BC4.9080503@ti.com>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz> <20130523022327.GB6159@kroah.com> <519D8876.9050405@suse.com> <51BF6BFF.7050705@suse.cz> <51BFE754.5080301@suse.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature";
	boundary="----enig2XEDXXSSTLPVPGILSWXGM"
Cc: Jiri Slaby <jslaby@suse.cz>, Jeff Mahoney <jeffm@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	<jirislaby@gmail.com>, <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	<linux-usb@vger.kernel.org>,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	<linux-geode@lists.infradead.org>, <linux-fbdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	<netdev@vger.kernel.org>, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>
To: Michal Marek <mmarek@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51BFE754.5080301@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

------enig2XEDXXSSTLPVPGILSWXGM
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 18/06/13 07:51, Michal Marek wrote:

>> Sam Ravnborg (the kconfig ex-maintainer) once wrote that he doesn't wa=
nt
>> to extend the kconfig language for this purpose (which I support). Tha=
t
>> a config option is fine and sufficient in this case [1]. Except he
>> called the config option "SHOW_ALL_DRIVERS". Adding the current
>> maintainer to CCs ;).
>=20
> I agree with Sam. 'depends on XY || COMPILE_TEST' is quite
> self-explanatory. And even if it's not, you can look up the help text
> for COMPILE_TEST. With "archdepends on" or "available on", you need to
> know what to look for to override the dependency.

I would rather have "depends on", when the code actually depends on
something (i.e. you can't compile/load the code otherwise), and "used
on"/"available on" when the code is just normally not used except on the
listed platforms (but nothing prevents from compiling and using the code
on all platforms).

But I'm fine with COMPILE_TEST or similar, I guess it's an acceptable
compromise and trivial to implement. Even if we had "used on" we'd still
need to update the Kconfig file when the code is being used on a new
platform, just like with COMPILE_TEST.

 Tomi



------enig2XEDXXSSTLPVPGILSWXGM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJRwBvEAAoJEPo9qoy8lh71VCYQAKwRBwrxv8PbNfV9MELqdlwK
O4Ilm1bxmCPvZ6wPRs+LmTCLiIisOQY+2Crt72XlgqDqh+uOXlSx5CzMMXUQYSaS
iEx2EGITSjqgW1tEALgEEfMLrguMbP9xifxBh/HT4qyATI3BX3IEAz/hp/YRGeRG
t2UwNKeEvfPDQuFH+lHFNTztLLNAG2vu2H3X+Krr74kTpWloZkTW5lA81IM7JcmK
Zs4pGDpT+6SxrxhTzsOv2Qj8Z0yGLkBvoFFQ+3uCTOM8zWSa98EVm2ktL3BmyyPy
05NY72pxdHj3PZQY8sEt1legOjSLsvwn3f9HbdlhKqNifBVl69b2XWFb4H1wlqCD
0rEo78IChYToeuRb++jf7T3phzZTX9mL5tpIn5zY3LwLWobALxItm+C92h5lN/ju
S82HV6sjD0vcz8V/7gtbnO8YKkBrvdH7zDkdhM7LBnNDLwQOTY3LlY2WhEBodVBH
pfRYXEi743VgydpJf4f1t45nNNw+r69cOuPSpMSeZhQZXKH6mqCXiDRbwrF74MMg
2R/w9MFK6ieI1XHhRPbzPUv5NDHHgUMl02hmFQPqXFqjPVrLEkAo0Kac5/cUm/K9
R9wuM8RN5ggOjuetoR1vH61S2UKL0yTgc+GprPRFu90kEB3WbhkKASDfHOBaPkYY
v+A4JtNSNGpiZgY4IV1y
=K7Rg
-----END PGP SIGNATURE-----

------enig2XEDXXSSTLPVPGILSWXGM--
