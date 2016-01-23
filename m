From: Willy Tarreau <w@1wt.eu>
Subject: Re: struct pid memory leak
Date: Sat, 23 Jan 2016 19:40:07 +0100
Message-ID: <20160123184007.GE1609@1wt.eu>
References: <CACT4Y+bZTpitMQOCyPcf4kKaXwghhEe3hmT=FtkrD3toZgoxxQ@mail.gmail.com> <1453481401.1223.396.camel@edumazet-glaptop2.roam.corp.google.com> <20160123180010.GB1609@1wt.eu> <CACT4Y+Z2fosqX4dRZQNEu=9zdxqCE=5CoQc1WQYsEdnH+MwK+g@mail.gmail.com>
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
In-Reply-To: <CACT4Y+Z2fosqX4dRZQNEu=9zdxqCE=5CoQc1WQYsEdnH+MwK+g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 23, 2016 at 07:14:33PM +0100, Dmitry Vyukov wrote:
> I've attached my .config.
> Also run this program in a parallel loop. I think it's leaking not
> every time, probably some race is involved.

Thank you. Just in order to confirm, am I supposed to see the
messages you quoted in dmesg ?

Thanks,
Willy
