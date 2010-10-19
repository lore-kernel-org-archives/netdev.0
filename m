From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [Ksummit-2010-discuss] [v2] Remaining BKL users, what to do
Date: Tue, 19 Oct 2010 21:41:22 +0100
Message-ID: <20101019214122.301ca754@lxorguk.ukuu.org.uk>
References: <201009161632.59210.arnd@arndb.de>
	<21406.1287512693@localhost>
	<20101019193735.GA4043@kroah.com>
	<201010192140.47433.oliver@neukum.org>
	<20101019202912.GA30133@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>, Valdis.Kletnieks@vt.edu,
	Dave Airlie <airlied@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101019202912.GA30133@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > you still need to switch off preemption.
> 
> Hm, how would you do that from within a driver?

Do we care - unless I misunderstand the current intel DRM driver handles
the i810 as well ?
