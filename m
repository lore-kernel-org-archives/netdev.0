From: Mark Brown <broonie@kernel.org>
Subject: Re: [PATCH] build some drivers only when compile-testing
Date: Wed, 19 Jun 2013 17:38:11 +0100
Message-ID: <20130619163810.GY1403@sirena.org.uk>
References: <1369214326-6558-1-git-send-email-jslaby@suse.cz>
 <20130523022327.GB6159@kroah.com>
 <519D8876.9050405@suse.com>
 <51BF6BFF.7050705@suse.cz>
 <51BFE754.5080301@suse.cz>
 <20130618081858.GD5461@arwen.pp.htv.fi>
 <51C01948.9060708@suse.cz>
 <20130618083425.GI5461@arwen.pp.htv.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mNqB7BSMRyhUYAix"
Cc: Jiri Slaby <jslaby@suse.cz>, Michal Marek <mmarek@suse.cz>,
	Jeff Mahoney <jeffm@suse.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	jirislaby@gmail.com, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Alexander Shishkin <alexander.shishkin@linux.intel.com>,
	linux-usb@vger.kernel.org,
	Florian Tobias Schandinat <FlorianSchandinat@gmx.de>,
	linux-geode@lists.infradead.org, linux-fbdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	netdev@vger.kernel.org, Ben Hutchings <ben@decadent.org.uk>,
	"Keller, Jacob E" <jacob.e.keller@intel.com>, tomi.valkeinen@ti.com
To: Felipe Balbi <balbi@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130618083425.GI5461@arwen.pp.htv.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--mNqB7BSMRyhUYAix
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 18, 2013 at 11:34:26AM +0300, Felipe Balbi wrote:

> MUSB alone has 8 different arch choices. Before, it used to be that core
> driver was dependendent on all of them, so whenever someone wanted to
> build MUSB for another arch, they had to introdude their glue code and
> modify the dependency of the core driver.

> Also EHCI, it works on pretty much everything, so does DWC3.

> DWC3 already has three possibilities but I know of at least 3 others
> which could show up soonish.

If the number of architectures supported is getting large enough then
it's probably reasonable to just enable the driver all the time,
probably it'll also appear on some PCI cards or something anyway.  The
things people are complaining about here are things that are clearly
unlikely to appear on other architectures like a particular SoC vendor's
custom IPs that they don't license out.

--mNqB7BSMRyhUYAix
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBAgAGBQJRwd5vAAoJELSic+t+oim9g2YP/RYTZksBIXcg2iutJN/y3mSr
40Ym0bnfUMTyKjWKWL0x4lFUYoC6uUQBx8X6zgPntXhgaPi11PGH0hY4rdSZuW9U
6uKsEcsVUydl5l2PT7f2e8nSlTUIHPljw0oj7Xtvgc7t9CT/BJePmIGjo32MnWaX
zOl0bBZKMfjUT4zhRh2/LU25Ljc8QQVD0kF/fEZ/5k8xsj1D5ljo8HPoFr8dMIUB
23bERwJFZ1e7nrsocRBtDeOjg9FTuQ1lrTgcMQP7MyL2wxgyI9zKFhtLFFtp+Fhm
jJfy4cnPhGurS8cWDje0ZWyKC3pJLvuywdaR/KxtDWGM96o91h6MGbJJXTJma8Sy
T9TSXROXj5htluVt3YEbHEBl/qtreFtgvC/4l3dpBth562dT1btsUpodRBg5Kj8Y
lwLXnSfhZdV2ao/aOZAFDkKl7vcP0iA98XM2FNmdPJTd5fVl8q7CWvg7sBRVSY2D
nmLVI8L/oIFy+9kJXmC75CJtcmzb2S1dL6DXd3d5C5hODEpZ7eUxAHIBI+6TnY99
cxMvGMwp/gIogO49BfBLedmRc6RTUh9W7IcRfMf7UhAlxQbMSru8eQAttK7nC/dd
AAbIqVUa7ASGgxVbQ9BlHBuDpG5mnWDI5BYurH3fdPAfSpbhBrQfamemkxQjissI
DSAfNx3TTLenz29EXaYq
=+oMe
-----END PGP SIGNATURE-----

--mNqB7BSMRyhUYAix--
