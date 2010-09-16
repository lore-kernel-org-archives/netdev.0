From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: Remaining BKL users, what to do
Date: Thu, 16 Sep 2010 10:49:09 -0400
Message-ID: <1284648549.23787.26.camel@gandalf.stny.rr.com>
References: <201009161632.59210.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
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
To: Arnd Bergmann <arnd@arndb.de>, Jens Axboe <jaxboe@fusionio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201009161632.59210.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-09-16 at 16:32 +0200, Arnd Bergmann wrote:
> The big kernel lock is gone from almost all code in linux-next, this is
> the status of what I think will happen to the remaining users:

> kernel/trace/blktrace.c:
> 	Should be easy. Ingo? Steven?
> 

Jens,

Git blame shows this to be your code (copied from block/blktrace.c from
years past).

Is the lock_kernel() needed here? (although Arnd did add it in 62c2a7d9)

-- Steve
