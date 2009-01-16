From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 16 Jan 2009 11:20:32 +0100
Message-ID: <87sknjeemn.fsf@basil.nowhere.org>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	<200901161503.13730.nickpiggin@yahoo.com.au>
	<20090115201210.ca1a9542.akpm@linux-foundation.org>
	<200901161746.25205.nickpiggin@yahoo.com.au>
	<20090116065546.GJ31013@parisc-linux.org>
	<1232092430.11429.52.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, sfr@canb.auug.org.au,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1232092430.11429.52.camel@ymzhang> (Yanmin Zhang's message of "Fri, 16 Jan 2009 15:53:50 +0800")
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Zhang, Yanmin" <yanmin_zhang@linux.intel.com> writes:


> I think that's because SLQB
> doesn't pass through big object allocation to page allocator.
> netperf UDP-U-1k has less improvement with SLQB.

That sounds like just the page allocator needs to be improved.
That would help everyone. We talked a bit about this earlier,
some of the heuristics for hot/cold pages are quite outdated
and have been tuned for obsolete machines and also its fast path
is quite long. Unfortunately no code currently.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.
