From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 23 Jan 2009 18:01:38 +0200
Message-ID: <1232726499.6094.103.camel@penberg-laptop>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <200901161503.13730.nickpiggin@yahoo.com.au>
	 <20090115201210.ca1a9542.akpm@linux-foundation.org>
	 <200901161746.25205.nickpiggin@yahoo.com.au>
	 <20090116065546.GJ31013@parisc-linux.org>
	 <1232092430.11429.52.camel@ymzhang>  <87sknjeemn.fsf@basil.nowhere.org>
	 <1232428583.11429.83.camel@ymzhang>
	 <alpine.DEB.1.10.0901211852060.18367@qirst.com>
	 <1232613395.11429.122.camel@ymzhang>
	 <1232615707.14549.6.camel@penberg-laptop>
	 <1232616517.11429.129.camel@ymzhang>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang>  <4979692B.3050703@cs.helsinki.fi>
	 <1232697998.6094.17.camel@penberg-laptop>
	 <1232699401.11429.163.camel@ymzhang>
	 <1232703989.6094.29.camel@penberg-laptop>
	 <alpine.DEB.1.10.0901231020030.21692@qirst.com>
	 <1232724691.6094.86.camel@penberg-laptop>
	 <alpine.DEB.1.10.0901231054590.32253@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Stephen Rothwell <sfr@canb.auug.org.au>,
	matthew.r.wilcox@intel.com, chinang.ma@intel.com,
	linux-kernel@vger.kernel.org, sharad.c.tripathi@intel.com,
	arjan@linux.intel.com, suresh.b.siddha@intel.com,
	harita.chilukuri@intel.com, douglas.w.styner@intel.com,
	peter.xihong.wang@intel.com, hubert.nueckel@intel.com,
	chris.mason@oracle.com, srostedt@redhat.com,
	linux-scsi@vger.kernel.org, andrew.vasquez@qlogic.com,
	anirban.chakraborty@qlogic.com, Ingo Molnar <mingo@elte.hu>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761038AbZAWQB5@vger.kernel.org>
In-Reply-To: <alpine.DEB.1.10.0901231054590.32253@qirst.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 23 Jan 2009, Pekka Enberg wrote:
> > I wonder why that doesn't happen already, actually. The slub_max_order
> > know is capped to PAGE_ALLOC_COSTLY_ORDER ("3") by default and obviously
> > order 3 should be as good fit as order 2 so 'fraction' can't be too high
> > either. Hmm.

On Fri, 2009-01-23 at 10:55 -0500, Christoph Lameter wrote:
> The kmalloc-8192 is new. Look at slabinfo output to see what allocation
> orders are chosen.

Yes, yes, I know the new cache a result of my patch. I'm just saying
that AFAICT, the existing logic should set the order to 3 but IIRC
Yanmin said it's 2.

			Pekka
