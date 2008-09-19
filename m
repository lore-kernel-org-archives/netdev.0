From: Matthew Wilcox <matthew@wil.cx>
Subject: Re: multiqueue interrupts...
Date: Fri, 19 Sep 2008 15:15:27 -0600
Message-ID: <20080919211527.GC13084@parisc-linux.org>
References: <41b516cb0809191050t6c9783dele8926f697854bb1@mail.gmail.com> <20080919181840.GE30956@parisc-linux.org> <36D9DB17C6DE9E40B059440DB8D95F520632FB45@orsmsx418.amr.corp.intel.com> <20080919.140922.131706817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	arjan@infradead.org, brice@myri.com, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palinux.external.hp.com ([192.25.206.14]:41413 "EHLO
	mail.parisc-linux.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751333AbYISVPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 17:15:44 -0400
Content-Disposition: inline
In-Reply-To: <20080919.140922.131706817.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2008 at 02:09:22PM -0700, David Miller wrote:
> Let irqbalanced implement the policy.  Just configure as many
> queues as possible and let it figure out what to do.

That isn't a great idea.  Some cards consume a significant amount of
resources per queue and the cost of each queue may be larger than the
benefit.

-- 
Matthew Wilcox				Intel Open Source Technology Centre
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
