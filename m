From: Jiri Kosina <jikos@kernel.org>
Subject: Re: [PATCH 1/4] list: introduce list_is_first()
Date: Thu, 10 Dec 2015 17:47:19 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1512101745360.9922@cbobk.fhfr.pm>
References: <305feb971ae11e192f35f25d66bb7b2e28e06c39.1449755818.git.geliangtang@163.com> <566995EA.80509@kernel.dk> <20151210152357.GG29872@treble.redhat.com> <56699BA8.1010009@kernel.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Josh Poimboeuf <jpoimboe@redhat.com>,
	Geliang Tang <geliangtang@163.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>,
	Josh Triplett <josh@joshtriplett.org>,
	Seth Jennings <sjenning@redhat.com>,
	Vojtech Pavlik <vojtech@suse.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"David S. Miller" <davem@davemloft.net>,
	live-patching@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-block@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jens Axboe <axboe@kernel.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56699BA8.1010009@kernel.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 10 Dec 2015, Jens Axboe wrote:

> It's a balance, as we also should not make APIs out of everything. As I said,
> purely my opinion, but I think the is_last/is_first have jumped the shark.

I don't have a strong opinion either way.

What I think we should do though, is to either have both (i.e accept this 
patchset) or have neither of them (i.e. drop list_is_last()).

Otherwise people are likely to be confused by such an asymetric API and 
will keep posting patches for it over and over again.

-- 
Jiri Kosina
SUSE Labs
