From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: hackbench regression due to commit 9dfc6e68bfe6e
Date: Wed, 07 Apr 2010 21:25:07 +0300
Message-ID: <4BBCCE03.5050104@cs.helsinki.fi>
References: <1269506457.4513.141.camel@alexs-hp.sh.intel.com>  <alpine.DEB.2.00.1003250942080.2670@router.home>  <1269570902.9614.92.camel@alexs-hp.sh.intel.com>  <1270114166.2078.107.camel@ymzhang.sh.intel.com>  <alpine.DEB.2.00.1004011050340.16531@router.home>  <1270195589.2078.116.camel@ymzhang.sh.intel.com>  <alpine.DEB.2.00.1004050853300.23149@router.home>  <i2z84144f021004051030k7ff5190cyc083aa12c552dfac@mail.gmail.com>  <4BBA8DF9.8010409@kernel.org>  <1270542497.2078.123.camel@ymzhang.sh.intel.com>  <alpine.DEB.2.00.1004061033330.18750@router.home>  <alpine.DEB.2.00.1004061552500.19151@router.home>  <1270591841.2091.170.camel@edumazet-laptop> <1270607668.2078.259.camel@ymzhang.sh.intel.com> <alpine.DEB.2.00.1004071130260.13261@router.home> <4BBCB7B7.4040901@cs.helsinki.fi> <4BBCB868
 .2000705@cs.helsinki.fi> <alpine.DEB.2.00.1004071319320.16159@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	alex.shi@intel.com,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"Ma, Ling" <ling.ma@intel.com>,
	"Chen, Tim C" <tim.c.chen@intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1004071319320.16159@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter wrote:
> On Wed, 7 Apr 2010, Pekka Enberg wrote:
> 
>> Oh, sorry, I think it's actually '____cacheline_aligned_in_smp' (with four
>> underscores) for per-cpu data. Confusing...
> 
> This does not particulary help to clarify the situation since we are
> dealing with data that can either be allocated via the percpu allocator or
> be statically present (kmalloc bootstrap situation).

Yes, I am an idiot. :-)
