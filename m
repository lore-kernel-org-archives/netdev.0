From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH] ehea: Fix a checksum issue on the receive path
Date: Wed, 13 Oct 2010 11:06:14 -0300
Message-ID: <4CB5BCD6.4000906@linux.vnet.ibm.com>
References: <1286513130.6536.467.camel@edumazet-laptop> <4CAF2732.90703@linux.vnet.ibm.com> <1286548577.2959.412.camel@edumazet-laptop> <20101009.092043.58419374.davem@davemloft.net> <20101009103136.341104c5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, fubar@us.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:35876 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab0JMOGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 10:06:21 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id o9DEDXNr013911
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 11:13:33 -0300
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9DECWtf1028272
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 11:12:33 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o9DE6FtG025782
	for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 11:06:16 -0300
In-Reply-To: <20101009103136.341104c5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2010 02:31 PM, Stephen Hemminger wrote:
> Also hardware checksum can be wrong/broken. By passing up a packet
> which the driver thinks is bad, the software can still work.
I see. Unfortunately ehea driver is dropping the packets that have a 
wrong checksum. I will work on the fix, and soon I will send the patch.

David,

Just to clarify, this patch that started this thead is not invalidated 
by this "problem". So, I'd like to see this patch committed on your 
tree. Does it make sense?

Thanks
Breno
