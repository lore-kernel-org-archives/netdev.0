From: Jan Kara <jack@suse.cz>
Subject: Re: Remaining BKL users, what to do
Date: Thu, 16 Sep 2010 17:04:59 +0200
Message-ID: <20100916150459.GA8437@quack.suse.cz>
References: <201009161632.59210.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: codalist@coda.cs.cmu.edu, autofs@linux.kernel.org,
	linux-media@vger.kernel.org, dri-devel@lists.freedesktop.org,
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
	Andrew Hendry <andrew.hendry@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201009161632.59210.arnd@arndb.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 16-09-10 16:32:59, Arnd Bergmann wrote:
> The big kernel lock is gone from almost all code in linux-next, this is
> the status of what I think will happen to the remaining users:
...
> fs/ncpfs:
> 	Should be fixable if Petr still cares about it. Otherwise suggest
> 	moving to drivers/staging if there are no users left.
  I think some people still use this...

> fs/udf:
> 	Not completely trivial, but probably necessary to fix. Project web
> 	site is dead, I hope that Jan Kara can be motivated to fix it though.
  Yeah, I can have a look at it.

								Honza

-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
