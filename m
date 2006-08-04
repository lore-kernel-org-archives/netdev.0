From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: Re: [RFC] irqbalance: Mark in-kernel irqbalance as obsolete, set
 to N by default
Date: Fri, 04 Aug 2006 07:25:10 -0700
Message-ID: <44D358C6.3080406@intel.com>
References: <44CE3F5E.4010305@intel.com> <20060803194550.9ff31bc1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	netdev@vger.kernel.org, arjan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:40868 "EHLO
	azsmga101-1.ch.intel.com") by vger.kernel.org with ESMTP
	id S1030239AbWHDO0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Aug 2006 10:26:33 -0400
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20060803194550.9ff31bc1.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Mon, 31 Jul 2006 10:35:26 -0700
> Auke Kok <auke-jan.h.kok@intel.com> wrote:
> 
>> We've recently seen a number of user bug reports against e1000 that the 
>> in-kernel irqbalance code is detrimental to network latency. The algorithm 
>> keeps swapping irq's for NICs from cpu to cpu causing extremely high network 
>> latency (>1000ms).
> 
> What kernel versions?  Some IRQ balancer fixes went in shortly after 2.6.17.

user reports show 2.6.17.1 having the problem, I'm trying to get more details 
information, and will ask if 2.6.18rc3 or so does better for them.

Cheers,

Auke
