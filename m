From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Mainline kernel OLTP performance update
Date: Fri, 23 Jan 2009 19:33:08 +1100
Message-ID: <200901231933.10101.nickpiggin@yahoo.com.au>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com> <1232617672.14549.25.camel@penberg-laptop> <1232679773.11429.155.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Pekka Enberg <penberg@cs.helsinki.fi>,
	Christoph Lameter <cl@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Matthew Wilcox <matthew@wil.cx>,
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
In-Reply-To: <1232679773.11429.155.camel@ymzhang>
Content-Disposition: inline
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 23 January 2009 14:02:53 Zhang, Yanmin wrote:

> 1) If I start CPU_NUM clients and servers, SLUB's result is about 2% better
> than SLQB's;

I'll have to look into this too. Could be evidence of the possible
TLB improvement from using bigger pages and/or page-specific freelist,
I suppose.

Do you have a scripted used to start netperf in that configuration?

