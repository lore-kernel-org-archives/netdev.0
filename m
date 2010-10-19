From: Valdis.Kletnieks@vt.edu
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 14:24:53 -0400
Message-ID: <21406.1287512693@localhost>
References: <201009161632.59210.arnd@arndb.de> <201010181742.06678.arnd@arndb.de> <20101018184346.GD27089@kroah.com> <AANLkTin2KPNNXvwcWphhM-5qexB14FS7M7ezkCCYCZ2H@mail.gmail.com>
            <20101019004004.GB28380@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1287512693_4982P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Dave Airlie <airlied@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
	codalist@telemann.coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org,
	autofs@linux.kernel.org, Jan Harkes <jaharkes@cs.cmu.edu>,
	Samuel Ortiz <samuel@sortiz.org>, Jan Kara <jack@suse.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, Anders Larsen <al@alarsen.net>,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	Bryan Schumaker <bjschuma@netapp.com>,
	Christoph Hellwig <hch@infradead.org>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	linux-fsdevel@vger.kernel.org,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>,
	Andrew Hendry <andrew.hendry@gmail.com>,
	linux-media@vger.kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: Your message of "Mon, 18 Oct 2010 17:40:04 PDT."
             <20101019004004.GB28380@kroah.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1287512693_4982P
Content-Type: text/plain; charset=us-ascii

On Mon, 18 Oct 2010 17:40:04 PDT, Greg KH said:

> I do have access to this hardware, but its on an old single processor
> laptop, so any work that it would take to help do this development,
> really wouldn't be able to be tested to be valid at all.

The i810 is a graphics chipset embedded on the memory controller, which
was designed for the Intel Pentium II, Pentium III, and Celeron CPUs.  Page 8
of the datasheet specifically says:

Processor/Host Bus Support
- Optimized for the Intel Pentium II processor, Intel Pentium III processor, and Intel
CeleronTM processor
- Supports processor 370-Pin Socket and SC242
connectors
- Supports 32-Bit System Bus Addressing
- 4 deep in-order queue; 4 or 1 deep request queue
- Supports Uni-processor systems only

So no need to clean it up for multiprocessor support.

http://download.intel.com/design/chipsets/datashts/29067602.pdf
http://www.intel.com/design/chipsets/specupdt/29069403.pdf



--==_Exmh_1287512693_4982P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFMveJ1cC3lWbTT17ARAt2tAKCceoSv2e1z2O+xGP5HZSPh9BLV0ACcDMdD
EqvUIRmf43WgTqzLN7IfCyo=
=wMsJ
-----END PGP SIGNATURE-----

--==_Exmh_1287512693_4982P--
