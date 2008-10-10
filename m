From: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 10 Oct 2008 17:25:10 +0400
Message-ID: <20081010132510.GA25834@tservice.net.ru>
References: <20081009231759.GA8664@tservice.net.ru> <20081010080910.GA31723@tservice.net.ru> <20081010091511.GC5116@elte.hu> <20081010113100.GA1030@tservice.net.ru> <20081010114042.GA19487@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Mike Galbraith <efault@gmx.de>, Nick Piggin <npiggin@suse.de>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759943AbYJJNZp@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081010114042.GA19487@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 10, 2008 at 01:40:42PM +0200, Ingo Molnar (mingo@elte.hu) wrote:
> make sure you have this fix in tip/master already:
> 
>   5b7dba4: sched_clock: prevent scd->clock from moving backwards
> 
> Note: Mike is 100% correct in suggesting that a very good cpu_clock() is 
> needed for precise scheduling.

The last commit is 5dc64a3442b98eaa and aforementioned changeset was included.
Result is quite bad:

vanilla 27: 	347.222
no TSO/GSO:	357.331
no hrticks:	382.983
no balance:	389.802
tip:		365.576

-- 
	Evgeniy Polyakov
