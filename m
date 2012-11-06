From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH v2 00/11] introduce random32_get_bytes() and random32_get_bytes_state()
Date: Tue, 6 Nov 2012 11:18:22 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7094@saturn3.aculab.com>
References: <1351957422-23243-1-git-send-email-akinobu.mita@gmail.com> <90816.1352178872@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <akpm@linux-foundation.org>,
	"Theodore Ts'o" <tytso@mit.edu>,
	"Artem Bityutskiy" <dedekind1@gmail.com>,
	"Adrian Hunter" <adrian.hunter@intel.com>,
	"David Woodhouse" <dwmw2@infradead.org>,
	<linux-mtd@lists.infradead.org>,
	"Eilon Greenstein" <eilong@broadcom.com>, <netdev@vger.kernel.org>,
	"Robert Love" <robert.w.love@intel.com>, <devel@open-fcoe.org>,
	"Michel Lespinasse" <walken@google.com>
To: <Valdis.Kletnieks@vt.edu>, "Akinobu Mita" <akinobu.mita@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <90816.1352178872@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> On Sun, 04 Nov 2012 00:43:31 +0900, Akinobu Mita said:
> > This patchset introduces new functions into random32 library for
> > getting the requested number of pseudo-random bytes.
> >
> > Before introducing these new functions into random32 library,
> > prandom32() and prandom32_seed() with "prandom32" prefix are
> > renamed to random32_state() and srandom32_state() respectively.
> >
> > The purpose of this renaming is to prevent some kernel developers
> > from assuming that prandom32() and random32() might imply that only
> > prandom32() was the one using a pseudo-random number generator by
> > prandom32's "p", and the result may be a very embarassing security
> > exposure.
> 
> Out of curiosity, why the '32'?  I'm just waiting for some kernel developer to
> do something stupid with this on a 64-bit arch because they think it's a 32-bit API. ;)
> 
> Should we bite the bullet and lose the 32, as long as we're churning the code *anyhow*?

Also why remove the 'pseudo' part of the name?
It is an important part of the name.

	David
