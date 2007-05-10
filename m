From: Gagan Arneja <gaagaan@gmail.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 14:14:05 -0700
Message-ID: <46438B1D.1050802@gmail.com>
References: <464370BA.3020907@hp.com>	<20070510.133216.95506791.davem@davemloft.net>	<46438568.1020403@hp.com> <20070510.140251.02302242.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, vladislav.yasevich@hp.com,
	ian.mcdonald@jandi.co.nz, krkumar2@in.ibm.com, johnpol@2ka.mipt.ru,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([65.113.40.141]:34371 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762281AbXEJVOG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:14:06 -0400
In-Reply-To: <20070510.140251.02302242.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 10 May 2007 13:49:44 -0700
> 
>> I'd think one would only do this in those situations/places where a
>> natural "out of driver" queue develops in the first place wouldn't
>> one?
> 
> Indeed.

And one builds in qdisc because your device sink is slow. There's 
nothing inherently there in the kernel encouraging Qdisc->q to grow. 
It's precisely these broken devices that can take advantage of cluster 
transmits.

--
Gagan
