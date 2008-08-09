From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [RFC][PATCH 1/1] cxgb3i: cxgb3 iSCSI initiator
Date: Sat, 09 Aug 2008 09:04:41 -0500
Message-ID: <489DA3F9.1080703@opengridcomputing.com>
References: <200808071145.03848.divy@chelsio.com>	<489C8BEB.8060001@opengridcomputing.com>	<489CC58D.4010606@pobox.com> <20080809.002840.167363463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, divy@chelsio.com, rdreier@cisco.com,
	kxie@chelsio.com, netdev@vger.kernel.org,
	open-iscsi@googlegroups.com, michaelc@cs.wisc.edu,
	daisyc@us.ibm.com, wenxiong@us.ibm.com, bhua@us.ibm.com,
	dm@chelsio.com, leedom@chelsio.com, linux-scsi@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:44530 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752174AbYHIOEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 10:04:46 -0400
In-Reply-To: <20080809.002840.167363463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Fri, 08 Aug 2008 18:15:41 -0400
>
>   
>> * security updates for TCP problems mean that a single IP address can be 
>> PARTIALLY SECURE, because security updates for kernel TCP stack and 
>> h/w's firmware are inevitably updated separately (even if distributed 
>> and compiled together).  Yay, we are introducing a wonderful new 
>> security problem here.
>>
>> * from a security, network scanner and packet classifier point of view, 
>> a single IP address no longer behaves like Linux.  It behaves like 
>> Linux... sometime.  Depending on whether it is a magic TCP port or not.
>>     
>
> I agree with everything Jeff has stated.
>
> Also, I find it ironic that the port abduction is being asked for in
> order to be "compatible with existing tools" yet in fact this stuff
> breaks everything.  You can't netfilter this traffic, you can't apply
> qdiscs to it, you can't execut TC actions on them, you can't do
> segmentation offload on them, you can't look for the usual TCP MIB
> statistics on the connection, etc. etc. etc.
>
> It is broken from every possible angle.
>   

I think a lot of these _could_ be implemented and integrated with the 
standard tools.





