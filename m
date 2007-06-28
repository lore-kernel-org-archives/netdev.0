From: Rick Jones <rick.jones2@hp.com>
Subject: Re: a maze of twisty stats, most different
Date: Thu, 28 Jun 2007 14:21:48 -0700
Message-ID: <4684266C.6020509@hp.com>
References: <4683F10F.6070007@hp.com>	<OF4B8149B6.D8E6CC86-ON88257308.006345F0-88257308.0064762A@us.ibm.com> <20070628.133617.43010120.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, csnook@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:45914 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758226AbXF1VVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jun 2007 17:21:51 -0400
In-Reply-To: <20070628.133617.43010120.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: David Stevens <dlstevens@us.ibm.com>
> Date: Thu, 28 Jun 2007 11:17:51 -0700
> 
> 
>>Comments?
> 
> 
> I think sysfs is a better model for MIBs, the extensibility we
> get for free since each SNMP MIB entry we want to add is simply
> a new file.
> 
> I'd be quite thrilled to apply a patch which implemented this.


OK, lets suppose this was done.  Assume we were speaking of a link-level 
stats  MIB,  would this then be something that did an ethtool-like call 
into each driver and so we are back to per-driver differences having to 
be dealt with by higher layers, or would we be having the drivers stick 
stats in multiple places?  Or are we back to wanting drivers to have a 
common set of stats they keep?

rick jones
unafraid to show his ignorance of how things work, and how :)
