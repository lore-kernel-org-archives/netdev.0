From: Chris Boot <bootc@bootc.net>
Subject: Re: KERNEL: assertion (!sk->sk_forward_alloc) failed at net/* (again)
Date: Tue, 16 May 2006 11:53:58 +0100
Message-ID: <57C97B28-45CC-4544-9780-D30E082A4011@bootc.net>
References: <16537920-30DB-4FF7-BD51-DC8517BF4321@bootc.net> <20060516105121.GA18677@2ka.mipt.ru>
Mime-Version: 1.0 (Apple Message framework v750)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel list <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	grsecurity@grsecurity.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from baldrick.bootc.net ([83.142.228.48]:26037 "EHLO
	baldrick.fusednetworks.co.uk") by vger.kernel.org with ESMTP
	id S1751773AbWEPKyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 06:54:01 -0400
In-Reply-To: <20060516105121.GA18677@2ka.mipt.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 16 May 2006, at 11:51, Evgeniy Polyakov wrote:

> On Tue, May 16, 2006 at 11:38:38AM +0100, Chris Boot  
> (bootc@bootc.net) wrote:
>> May 16 09:15:12 baldrick kernel: [6442250.504000] KERNEL:  
>> assertion (!
>> sk->sk_forward_alloc) failed at net/core/stream.c (283)
>> May 16 09:15:12 baldrick kernel: [6442250.513000] KERNEL:  
>> assertion (!
>> sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (150)
>>
>> tcp segmentation offload: on
>
> This bug was fixed in .10 in stack and .12 in e1000 driver
> (probably unrelated to your problem, if you do not have packet plit
> option enabled).

Aha, right. Well, I've got an upgrade to .16 ready to go and  
scheduled for Friday. What's interesting is that I never saw this  
problem come up before, and I've gone through each major interation  
of the kernel since 2.6.9...

Cheers,
Chris

-- 
Chris Boot
bootc@bootc.net
http://www.bootc.net/


