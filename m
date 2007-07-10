From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 0/1] ixgbe: Support for Intel(R) 10GbE PCI Express adapters
 -	Take #2
Date: Tue, 10 Jul 2007 14:00:49 -0400
Message-ID: <4693C951.3040608@garzik.org>
References: <20070710174504.9615.10053.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org, auke-jan.h.kok@intel.com,
	hch@infradead.org, shemminger@linux-foundation.org,
	nhorman@tuxdriver.com, inaky@linux.intel.com, mb@bu3sch.de
To: Ayyappan.Veeraiyan@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:32835 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754288AbXGJSAx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 14:00:53 -0400
In-Reply-To: <20070710174504.9615.10053.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayyappan.Veeraiyan@intel.com wrote:
> 7. NAPI mode uses sigle Rx queue and so fake netdev usage is removed.
> 8. Non-NAPI mode is added.

Honestly I'm not sure about drivers that have both NAPI and non-NAPI paths.

Several existing drivers do this, and in almost every case, I tend to 
feel the driver would benefit from picking one approach, rather than 
doing both.

Doing both tends to signal that the author hasn't bothered to measure 
the differences between various approaches, and pick a clear winner.

I strongly prefer NAPI combined with hardware interrupt mitigation -- it 
helps with multiple net interfaces balance load across the system, at 
times of high load -- but I'm open to other solutions as well.

So...  what are your preferences?  What is the setup that gets closest 
to wire speed under Linux?  :)

	Jeff


