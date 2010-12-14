From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Fixing LRO configuration
Date: Tue, 14 Dec 2010 11:01:35 -0200
Message-ID: <4D076AAF.5040505@linux.vnet.ibm.com>
References: <1291833062-27446-1-git-send-email-leitao@linux.vnet.ibm.com> <AANLkTimvL2TdD9eYQMLZW65ESKbame818ObzjPYoBhPL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, davem@davemloft.net, netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:40651 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759168Ab0LNNBn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 08:01:43 -0500
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id oBEDIsQU026812
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:18:54 -0200
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oBED8mDv651398
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:08:51 -0200
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oBED1NTR005586
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 11:01:24 -0200
In-Reply-To: <AANLkTimvL2TdD9eYQMLZW65ESKbame818ObzjPYoBhPL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

On 12/12/2010 10:39 PM, Jesse Gross wrote:
> I don't think that this should enable those vlan offloading flags.
I just inserted ETH_FLAG_TXVLAN and ETH_FLAG_RXVLAN there because when I 
call ethtool -K ethX lro on/off, it sends the ETH_FLAG_LRO plus the vlan 
flags if they are enabled (and they are by default).

So, if it doesn't make sense to be toggled, I can mask these flags at 
ehea_set_flags(). so that it doesn't arrive at ethtool_op_set_flags().

Does it sound better to you ?

Thanks
Breno


