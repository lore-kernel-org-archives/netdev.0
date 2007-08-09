From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH RFC]: napi_struct V5
Date: Thu, 09 Aug 2007 01:32:24 -0400
Message-ID: <46BAA6E8.4050107@garzik.org>
References: <OFA2F18805.38AA0BD0-ON87257331.005367FB-88257331.0027BEED@us.ibm.com>	<1186587154.5155.43.camel@localhost> <20070808.212353.105403708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, xma@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, rusty@rustcorp.com.au,
	shemminger@linux-foundation.org
To: David Miller <davem@davemloft.net>, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44064 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754917AbXHIFcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2007 01:32:41 -0400
In-Reply-To: <20070808.212353.105403708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Wed, 08 Aug 2007 11:32:34 -0400
> 
>> Think of a box where you have other network interfaces, the way you
>> are implementing currently implies you are going to be very unfair to 
>> the other interfaces on the box. 
> 
> This was the point I was trying to make the other day.

Agreed.  That's one of the big selling points of NAPI when I talk to 
people -- the entire system works towards a single equilibrium, when 
multiple interfaces are under load.

And conversely, without NAPI, the driver has no knowledge of conditions 
outside its limited view, and resource imbalances inevitably ensue. 
Particularly so for infiniband, 10gb, etc. where the natural motivation 
of the driver writer appears to trend towards "performance even at the 
expense of other system entities."

	Jeff



