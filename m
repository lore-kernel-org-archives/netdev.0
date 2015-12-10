From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 1/4] list: introduce list_is_first()
Date: Thu, 10 Dec 2015 07:35:40 -0800
Message-ID: <20151210153540.GA27533@infradead.org>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com>
 <566995EA.80509@kernel.dk>
 <20151210152357.GG29872@treble.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jens Axboe <axboe@kernel.dk>, Geliang Tang <geliangtang@163.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Seth Jennings <sjenning@redhat.com>,
	Jiri Kosina <jikos@kernel.org>,
	Vojtech Pavlik <vojtech@suse.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	live-patching@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
To: Josh Poimboeuf <jpoimboe@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151210152357.GG29872@treble.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 10, 2015 at 09:23:57AM -0600, Josh Poimboeuf wrote:
> Personally I would disagree.  Something like:
> 
>   if (list_is_first(&rq->queuelist, &nd->queue))
> 
> is much more readable to me than:
> 
>   if (rq->queuelist.prev == &nd->queue)
> 
> The first one takes no effort for me -- it's almost English.  While the
> second one takes me a few seconds (and some precious brain cycles) to
> decipher.
> 
> Maybe whether it's readable depends on how many years you've been
> looking at the pattern.  But IMHO we shouldn't make "having x # of years
> staring at kernel code" a prerequisite for being able to read kernel
> code.

I think understanding the list.h semantics is a requirement for writing
(or reading) non-trivial kernel code.
