From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket
 filter
Date: Fri, 16 Nov 2007 12:13:10 +0800
Message-ID: <473D18D6.6050903@cn.fujitsu.com>
References: <473D0482.4050705@cn.fujitsu.com>	<20071115.185403.138420969.davem@davemloft.net>	<473D0BF8.3060902@cn.fujitsu.com> <20071115.200431.102331739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:56161 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1756574AbXKPEPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 23:15:30 -0500
In-Reply-To: <20071115.200431.102331739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller said the following on 2007-11-16 12:04:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Fri, 16 Nov 2007 11:18:16 +0800
> 
> That's right, InDataGrams will increase even if we haven't
> verified the checksum yet.
> 
> When the user does a recvmsg() or a poll() on the socket,
> we will notice the bad checksum then and increment InErrors.
> We could in this case correct the InDatagrams counter by
> decrementing it in this case.
> 

Yes, it's a good idea.
I will make the patch and test it.
Thank dave for the suggestion.

