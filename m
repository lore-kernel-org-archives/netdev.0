From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] net IPv6: Remove unnecessary argument of ndisc_send_ns
 and ndisc_send_na
Date: Mon, 14 Apr 2014 14:13:18 +0900
Message-ID: <534B6E6E.5020104@linux-ipv6.org>
References: <534B58AA.80704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Balakumaran Kannan <kumaran.4353@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:52751 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750905AbaDNFNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 01:13:20 -0400
In-Reply-To: <534B58AA.80704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Balakumaran Kannan wrote:
> The 'neigh' argument of 'ndisc_send_ns' and 'ndisc_send_na' are not used in
> these functions. So this could be removed.
> 
> And a minor change of 'optlen' assignment in those functions. the compound
> addition and assignment operator is not needed as 'optlen' value is always
> zero.

Do not mix changes.

Well, it is for future extension so that we can prepend another option
easier.  Do you see any penalty here?


> 
> Signed-off-by: Balakumaran Kannan <kumaran.4353@gmail.com>
> ---
> I am not sure whether 'neigh' argument is intentional or planned for any
> future use. If you find this is unnecessary, this patch could be considered.
> 
> And ndisc_send_na is used as a function pointer in ipv6_stub. This may affect anybody
> using this structure. But with default configuration built, I didn't get any error or
> warning. Kindly consider this scenario also. 

drivers/net/usb/cdc_mbim.c uses it at least.

--yoshfuji
