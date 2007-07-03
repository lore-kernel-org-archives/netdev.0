From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ixgbe: Introduce new 10GbE driver for Intel 82598 based
 PCI Express adapters...
Date: Mon, 02 Jul 2007 20:11:36 -0400
Message-ID: <46899438.3080504@garzik.org>
References: <4688F512.3030801@garzik.org> <20070702214238.GA7085@infradead.org> <46897611.9020207@intel.com> <200707030010.25431.mb@bu3sch.de> <46897934.5040101@garzik.org> <468990D8.6040604@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>,
	Christoph Hellwig <hch@infradead.org>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"Veeraiyan, Ayyappan" <ayyappan.veeraiyan@intel.com>,
	netdev@vger.kernel.org, arjan@linux.intel.com,
	akpm@linux-foundation.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55475 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755629AbXGCALo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 20:11:44 -0400
In-Reply-To: <468990D8.6040604@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> but let's stay constructive here:
> 
> ~/git/linux-2.6 $ grep -r 'unsigned int.*:1;' * | wc -l
> 748
> 
> Is anyone going to fix those? If we don't, someone will certainly again 
> submit patches to add more of these bitfields, after all, some very 
> prominent parts of the kernel still use them. Only recently for instance 
> mac80211 merged like 30 of these.... and drivers/net, include etc.. 
> certainly has a lot of these.


There is a lot of crap in the kernel.  Just look at all the grotty SCSI 
or char drivers, for example.  The first task is to avoid adding more 
crap :)

	Jeff


