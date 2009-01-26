From: Rick Jones <rick.jones2@hp.com>
Subject: Re: care and feeding of netperf (Re: Mainline kernel OLTP	performance
 update)
Date: Mon, 26 Jan 2009 10:26:15 -0800
Message-ID: <497E0047.5080307@hp.com>
References: <BC02C49EEB98354DBA7F5DD76F2A9E800317003CB0@azsmsx501.amr.corp.intel.com>	<1232617672.14549.25.camel@penberg-laptop>	<1232679773.11429.155.camel@ymzhang>	<200901231933.10101.nickpiggin@yahoo.com.au>	<1232701348.11429.170.camel@ymzhang>  <497A0F27.3030801@hp.com> <1232766180.11429.202.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
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
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1232766180.11429.202.camel@ymzhang>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>To get quick profiles, that form of aggregate netperf is OK - just the one 
>>iteration with background processes using a moderatly long run time.  However, 
>>for result reporting, it is best to (ab)use the confidence intervals 
>>functionality to try to avoid skew errors.
> 
> Yes. My formal testing uses -i 50. I just wanted a quick testing. If I need
> finer-tuning or investigation, I would turn on more options.

Netperf will silently clip that to 30 as that is all the built-in tables know.

> Thanks again. I learned a lot.

Feel free to wander over to netperf-talk over at netperf.org if you want to talk 
some more about the care and feeding of netperf.

happy benchmarking,

rick jones
