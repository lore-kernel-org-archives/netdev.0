From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH net-next] ipv6: fix ipv6_prefix_equal64_half mask conversion
Date: Thu, 17 Jan 2013 12:36:30 +0900
Message-ID: <50F771BE.7070309@linux-ipv6.org>
References: <1358371817-15378-1-git-send-email-fabio.baltieri@linaro.org> <20130116.163729.1934084260354327196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:43521 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757238Ab3AQDgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:36:32 -0500
In-Reply-To: <20130116.163729.1934084260354327196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Fabio Baltieri <fabio.baltieri@linaro.org>
> Date: Wed, 16 Jan 2013 22:30:17 +0100
> 
>> Fix the 64bit optimized version of ipv6_prefix_equal to convert the
>> bitmask to network byte order only after the bit-shift.
>>
>> The bug was introduced in:
>>
>> 3867517 ipv6: 64bit version of ipv6_prefix_equal().
>>
>> Signed-off-by: Fabio Baltieri <fabio.baltieri@linaro.org>
> 
> Applied, thanks.
> 

Sorry for the mess.

I'm not seeing this in net-next so far, though I can see my
patch for ip6_flow_hdr() which you "applied" later.
Do I miss something?

--yoshfuji
