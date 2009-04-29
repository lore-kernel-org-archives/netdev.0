From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net-next PATCH 1/3] ixgbe: enable HW RSC for 82599
Date: Wed, 29 Apr 2009 09:16:48 -0700
Message-ID: <49F87D70.4060707@intel.com>
References: <20090428084236.32710.14750.stgit@localhost.localdomain>	<20090428.015535.42660210.davem@davemloft.net>	<alpine.WNT.2.00.0904281648300.5352@jbrandeb-desk1.amr.corp.intel.com> <20090428.175446.191949653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16961 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752254AbZD2QRB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Apr 2009 12:17:01 -0400
In-Reply-To: <20090428.175446.191949653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
> Date: Tue, 28 Apr 2009 17:12:10 -0700 (Pacific Daylight Time)
> 
>> ah, you're right, but this features enables our new hardware that can do 
>> LRO in hardware, and then GRO can work on top of it if necessary.  We 
>> wanted some way to turn it off and overloaded the LRO flag to do so.
> 
> That ugly.  And the kernel is going to turn this off on you
> when the user enables either forwarding or bridging.

That would likely be a desirable consequence.  If the interface is used 
for forwarding or bridging we probably would want to turn the feature 
off since it has many of the same limitations as software LRO.  Then we 
can let software GRO take over and handle all of the coalescing.

Thanks,

Alex



