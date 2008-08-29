From: Breno Leitao <leitao@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1 net-2.6] Re-enable IP when MTU > 68
Date: Fri, 29 Aug 2008 12:23:03 -0300
Message-ID: <48B81457.9010105@linux.vnet.ibm.com>
References: <48B80D6B.5030007@linux.vnet.ibm.com> <20080829150506.GO7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Lorandi <rafaello@br.ibm.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from igw2.br.ibm.com ([32.104.18.25]:50854 "EHLO igw2.br.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757494AbYH2QMs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 12:12:48 -0400
Received: from mailhub3.br.ibm.com (mailhub3 [9.18.232.110])
	by igw2.br.ibm.com (Postfix) with ESMTP id 559CB17F612
	for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 12:58:02 -0300 (BRT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.18.232.46])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m7TFhcla2031660
	for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 13:12:43 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7TFN52c022498
	for <netdev@vger.kernel.org>; Fri, 29 Aug 2008 12:23:06 -0300
In-Reply-To: <20080829150506.GO7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben, 

Ben Hutchings wrote:
> Should be >= to match the other tests.  And it would really be cleaner to
> use something like
> 
> 	static inline bool inetdev_valid_mtu(unsigned mtu)
> 	{
> 		return mtu >= 68;
> 	}
Where is the best place to insert this function ?
