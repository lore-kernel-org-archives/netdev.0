From: Grant Grundler <grundler@google.com>
Subject: Re: care and feeding of netperf (Re: Mainline kernel OLTP performance
	update)
Date: Fri, 23 Jan 2009 10:51:18 -0800
Message-ID: <da824cf30901231051m5d11678k5eb2086ac18457ff@mail.gmail.com>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>
	 <1232617672.14549.25.camel@penberg-laptop>
	 <1232679773.11429.155.camel@ymzhang>
	 <200901231933.10101.nickpiggin@yahoo.com.au>
	 <1232701348.11429.170.camel@ymzhang> <497A0F27.3030801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	Nick Piggin <nickpiggin@yahoo.com.au>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
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
To: Rick Jones <rick.jones2@hp.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <497A0F27.3030801@hp.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 23, 2009 at 10:40 AM, Rick Jones <rick.jones2@hp.com> wrote:
...
> And I would probably add the -c and -C options to have netperf report
> service demands.

For performance analysis, the service demand is often more interesting
than the absolute performance (which typically only varies a few Mb/s
for gigE NICs). I strongly encourage adding -c and -C.

grant
