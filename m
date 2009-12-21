From: Felix Radensky <felix@embedded-sol.com>
Subject: Re: tg3: link is permanently down after ifdown and ifup
Date: Mon, 21 Dec 2009 23:52:22 +0200
Message-ID: <4B2FEE16.2020808@embedded-sol.com>
References: <4B056158.5060104@embedded-sol.com> <4B056D85.5010904@embedded-sol.com> <1258671053.14964.20.camel@nseg_linux_HP1.broadcom.com> <4B1F631E.5030908@embedded-sol.com> <20091210011931.GA30802@xw6200.broadcom.net> <4B2E547E.3040806@embedded-sol.com> <20091221181919.GB23940@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vega.surpasshosting.com ([72.29.83.9]:55061 "EHLO
	vega.surpasshosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757280AbZLUVxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2009 16:53:10 -0500
In-Reply-To: <20091221181919.GB23940@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, Matt

Matt Carlson wrote:
>>
>> There was another problem in 2.6.32 that I reported, namely kernel soft 
>> lockup
>> when link is synchronized at 100Mbit/sec and tg3 with 57780 goes down . Were
>> you able to reproduce it ?
>>     
>
> No, but perhaps I don't understand the problem well enough.  Are you
> saying that you encounter the problem when you run
> 'ifconfig bcm57780 down', or is it that losing link itself causes the
> problem?
>
>   
It is enough to connect the NIC to 10/100 switch and run 'ifconfig ethX 
down' to reproduce
the problem.

Thanks.

Felix.
