From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 16 Jan 2009 18:06:59 +1100
Message-ID: <200901161807.01342.nickpiggin@yahoo.com.au>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com> <200901161746.25205.nickpiggin@yahoo.com.au> <20090116065546.GJ31013@parisc-linux.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	sfr@canb.auug.org.au, matthew.r.wilcox@intel.com,
	chinang.ma@intel.com, linux-kernel@vger.kernel.org,
	sharad.c.tripathi@intel.com, arjan@linux.intel.com,
	andi.kleen@intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com,
	"Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
To: Matthew Wilcox <matthew@wil.cx>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <20090116065546.GJ31013@parisc-linux.org>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 16 January 2009 17:55:47 Matthew Wilcox wrote:
> On Fri, Jan 16, 2009 at 05:46:23PM +1100, Nick Piggin wrote:
> > Intel's OLTP shows SLQB is "neutral" to SLAB. That is, literally within
> > their measurement confidence interval. If it comes down to it, I think we
> > could get them to do more runs to narrow that down, but we're talking a
> > couple of tenths of a percent already.
>
> I think I can speak with some measure of confidence for at least the
> OLTP-testing part of my company when I say that I have no objection to
> Nick's planned merge scheme.
>
> I believe the kernel benchmark group have also done some testing with
> SLQB and have generally positive things to say about it (Yanmin added to
> the gargantuan cc).
>
> Did slabtop get fixed to work with SLQB?

Yes the old slabtop that works on /proc/slabinfo works with SLQB (ie. SLQB
implements /proc/slabinfo).

Lin Ming recently also ported the SLUB /sys/kernel/slab/ specific slabinfo
tool to SLQB. Basically it reports in-depth internal event counts etc. and
can operate on individual caches, making it very useful for performance
"observability" and tuning.

It is hard to come up with a single set of statistics that apply usefully
to all the allocators. FWIW, it would be a useful tool to port over to
SLAB too, if we end up deciding to go with SLAB.

