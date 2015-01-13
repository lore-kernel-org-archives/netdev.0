From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fwd: [rhashtable] WARNING: CPU: 0 PID: 10 at
 kernel/locking/mutex.c:570 mutex_lock_nested()
Date: Tue, 13 Jan 2015 08:41:26 +0000
Message-ID: <20150113084126.GE20387@casper.infradead.org>
References: <20150110194803.GA9033@wfg-t540p.sh.intel.com>
 <54B3259B.7080601@windriver.com>
 <20150112124216.GA26570@casper.infradead.org>
 <54B4CE3E.8020009@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, lkp@01.org,
	Netdev <netdev@vger.kernel.org>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54B4CE3E.8020009@windriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/13/15 at 03:50pm, Ying Xue wrote:
> On 01/12/2015 08:42 PM, Thomas Graf wrote:
> > On 01/12/15 at 09:38am, Ying Xue wrote:
> >> Hi Thomas,
> >>
> >> I am really unable to see where is wrong leading to below warning
> >> complaints. Can you please help me check it?
> > 
> > Not sure yet. It's not your patch that introduced the issue though.
> > It merely exposed the affected code path.
> >
> > Just wondering, did you test with CONFIG_DEBUG_MUTEXES enabled?
> > 
> > 
> 
> After I enable above option, I don't find similar complaints during my
> testing.

I can't reproduce it in my KVM box either so far. It looks like a
mutex_lock() on an uninitialized mutex or use after free but I can't
find such a code path so far.
