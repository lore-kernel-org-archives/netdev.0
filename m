From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [patch net/stable] ipv6/exthdrs: accept tlv which includes only
 padding
Date: Sun, 08 Sep 2013 13:20:34 +0900
Message-ID: <522BFB12.6040700@linux-ipv6.org>
References: <1378476145-6282-1-git-send-email-jiri@resnulli.us> <alpine.LNX.2.00.1309071427120.1262@heraclitus> <20130907.215020.38125291010941900.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: eldad@fogrefinery.com, jiri@resnulli.us, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58610 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751232Ab3IHEak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Sep 2013 00:30:40 -0400
In-Reply-To: <20130907.215020.38125291010941900.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

David Miller wrote:
> From: Eldad Zack <eldad@fogrefinery.com>
> Date: Sat, 7 Sep 2013 14:31:36 +0200 (CEST)
> 
>> On Fri, 6 Sep 2013, Jiri Pirko wrote:
>>
>>> Current behaviour breaks TAHI Test v6LC.1.2.6.
>>
>> I'm not familiar with this, but IMHO the test should be reversed :)
> 
> I think I agree with Eldad on this, and that TAHI should be adjusted
> to have more reasonable expectations of an implementation.
> 

The tests (including packet formats) are based on the test specification:
 https://www.ipv6ready.org/?page=documents&tag=ipv6-core-protocols

If we want to change the tests, I think we need to consult with IPv6
Forum.

Regards,

--yoshfuji
