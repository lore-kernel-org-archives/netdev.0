From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 22:48:34 +0200
Message-ID: <201010192248.34501.arnd@arndb.de>
References: <201009161632.59210.arnd@arndb.de> <20101019202912.GA30133@kroah.com> <20101019214122.301ca754@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, Oliver Neukum <oliver@neukum.org>,
	Valdis.Kletnieks@vt.edu, Dave Airlie <airlied@gmail.com>,
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
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101019214122.301ca754@lxorguk.ukuu.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 19 October 2010 22:41:22 Alan Cox wrote:
> > > you still need to switch off preemption.
> > 
> > Hm, how would you do that from within a driver?
> 
> Do we care - unless I misunderstand the current intel DRM driver handles
> the i810 as well ?

No, it does handle all devices supported by i830.ko (830M, 845M, 854, 855GM,
865G), but not those supported by i810.ko (810, 815).

	Arnd
