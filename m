From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [v2] Remaining BKL users, what to do
Date: Mon, 18 Oct 2010 12:19:24 -0400
Message-ID: <20101018161924.GA9571@infradead.org>
References: <201009161632.59210.arnd@arndb.de>
 <201010181742.06678.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: codalist@coda.cs.cmu.edu,
	ksummit-2010-discuss@lists.linux-foundation.org,
	autofs@linux.kernel.org, linux-media@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	Christoph Hellwig <hch@infradead.org>,
	Mikulas Patocka <mikulas@artax.karlin.mff.cuni.cz>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Petr Vandrovec <vandrove@vc.cvut.cz>,
	Anders Larsen <al@alarsen.net>, Jan Kara <jack@suse.cz>,
	Evgeniy Dushistov <dushistov@mail.ru>,
	Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	Samuel Ortiz <samuel@sortiz.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	Andrew Hendry <andrew.hendry@gmail.com>,
	David Miller <davem@davemloft.net>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	Bryan Schumaker <bjschuma@netapp.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201010181742.06678.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before we get into all these fringe drivers:

 - I've not seen any progrss on ->get_sb BKL removal for a while
 - locks.c is probably a higher priorit, too.
