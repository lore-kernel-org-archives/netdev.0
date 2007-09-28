From: "Randy Macleod" <macleodr@nortel.com>
Subject: Re: UDP Out 0f Sequence
Date: Fri, 28 Sep 2007 13:22:28 -0400
Message-ID: <46FD3854.8010702@nortel.com>
References: <F444CAE5E62A714C9F45AA292785BED30EB9759A@esng11p33001.sg.csfb.com> <4512C10A.4070303@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	"'David Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kn.nortel.com ([47.140.192.55]:55142 "EHLO
	zrtps0kn.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbXI1Rzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 13:55:50 -0400
In-Reply-To: <4512C10A.4070303@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Majumder, Rajib wrote:
>> Let's say we have 2 uniprocessor hosts connected back to back. Is
>> there any possibility of an out-of-order scenario on recv? 
> 
> Your application should be written on the assumption that it is 
> possible, regardless of the specifics of the hosts involved, however 
> unlikely they may be to reorder traffic.
> 
>  > Is this same for all kernel (linux/solaris)?
> 
> Your application should be written on the assumtion that it is possible, 
> regardless of the specifics of the OSes involved, however unlikely they 
> may be to reorder traffic.

Or you should use a different protocol stack that guarantees order.
Have you considered TCP, DCCP or even TIPC?
The solution depends on your application requirements and your
projects tolerance for risk.

// Randy

