From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Wed, 25 Mar 2009 14:22:19 -0600
Message-ID: <49CA927B.9080709@nortel.com>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com> <20090324.155756.214460004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt_Domsch@dell.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:58872 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbZCYUWm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 16:22:42 -0400
In-Reply-To: <20090324.155756.214460004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Matt Domsch <Matt_Domsch@dell.com>
> Date: Tue, 24 Mar 2009 10:46:17 -0500
> 
>> Problem: Users expect on-motherboard NICs to be named eth0..ethN.
>> This can be difficult to achieve.
> 
> I learned a long time ago that eth0 et al. have zero meaning.
> 
> If the system firmware folks gave us topology information with respect
> to these things, we could export something that tools such as
> NetworkManager, iproute2, etc. could use.

<snip>

> I guess it's easier to spew about MAC addresses and other
> irrelevant topics than try to solve this problem properly. :-)

What about things like USB network adapters where the topology is not 
fixed?  Presumably we would want to use some sort of unique identifier, 
and the MAC comes to mind.  Of course, then you run into the problem of 
how to deal with duplicate MACs.

Chris
