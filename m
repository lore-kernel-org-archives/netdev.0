From: Willy Tarreau <w@1wt.eu>
Subject: Re: struct pid memory leak
Date: Sun, 24 Jan 2016 03:38:24 +0100
Message-ID: <20160124023824.GA13942@1wt.eu>
References: <CACT4Y+bZTpitMQOCyPcf4kKaXwghhEe3hmT=FtkrD3toZgoxxQ@mail.gmail.com> <1453481401.1223.396.camel@edumazet-glaptop2.roam.corp.google.com> <20160123180010.GB1609@1wt.eu> <CACT4Y+Z2fosqX4dRZQNEu=9zdxqCE=5CoQc1WQYsEdnH+MwK+g@mail.gmail.com> <20160123184007.GE1609@1wt.eu> <CACT4Y+Y9f838pAMnvkPzEDwWWE0Ge1xLNetwjKFk0ccZ51YgHQ@mail.gmail.com> <20160124021145.GA12367@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Michal Hocko <mhocko@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Vladimir Davydov <vdavydov@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Eric Dumazet <edumazet@google.com>,
	LKML <linux-kernel@vger.kernel.org>,
	syzkaller <syzkaller@googlegroups.com>,
	Kostya Serebryany <kcc@google.com>,
	Alexander Potapenko <glider@google.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160124021145.GA12367@1wt.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jan 24, 2016 at 03:11:45AM +0100, Willy Tarreau wrote:
> It doesn't report this on 3.10.

To be more precise, kmemleak reports the issue on 3.13 and not on 3.12.
I'm not sure if it's reliable enough to run a bisect though.

Willy
