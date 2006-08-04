From: Andrew Morton <akpm@osdl.org>
Subject: Re: [RFC] irqbalance: Mark in-kernel irqbalance as obsolete, set to
 N by default
Date: Thu, 3 Aug 2006 19:45:50 -0700
Message-ID: <20060803194550.9ff31bc1.akpm@osdl.org>
References: <44CE3F5E.4010305@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, jesse.brandeburg@intel.com,
	john.ronciak@intel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org, arjan@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030296AbWHDCpx@vger.kernel.org>
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44CE3F5E.4010305@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 31 Jul 2006 10:35:26 -0700
Auke Kok <auke-jan.h.kok@intel.com> wrote:

> We've recently seen a number of user bug reports against e1000 that the 
> in-kernel irqbalance code is detrimental to network latency. The algorithm 
> keeps swapping irq's for NICs from cpu to cpu causing extremely high network 
> latency (>1000ms).

What kernel versions?  Some IRQ balancer fixes went in shortly after 2.6.17.

It would be better if poss to fix the balancer rather than deprecating it.
