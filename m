From: Rick Jones <rick.jones2@hp.com>
Subject: Re: UDP Out 0f Sequence
Date: Thu, 21 Sep 2006 09:42:50 -0700
Message-ID: <4512C10A.4070303@hp.com>
References: <F444CAE5E62A714C9F45AA292785BED30EB9759A@esng11p33001.sg.csfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:701 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1751320AbWIUQmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 12:42:51 -0400
To: "Majumder, Rajib" <rajib.majumder@credit-suisse.com>
In-Reply-To: <F444CAE5E62A714C9F45AA292785BED30EB9759A@esng11p33001.sg.csfb.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Majumder, Rajib wrote:
> Let's say we have 2 uniprocessor hosts connected back to back. Is
> there any possibility of an out-of-order scenario on recv? 

Your application should be written on the assumption that it is 
possible, regardless of the specifics of the hosts involved, however 
unlikely they may be to reorder traffic.

 > Is this same for all kernel (linux/solaris)?

Your application should be written on the assumtion that it is possible, 
regardless of the specifics of the OSes involved, however unlikely they 
may be to reorder traffic.

rick jones
