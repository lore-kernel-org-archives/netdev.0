From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: i386 vs x86_64 struct tpacket_hdr layout
Date: Fri, 20 Dec 2013 19:45:12 +0100
Message-ID: <52B49038.3070307@redhat.com>
References: <52B4465E.2090904@aimvalley.nl> <20131220.133854.672157982782686878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nvbolhuis@aimvalley.nl, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43331 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039Ab3LTSpU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Dec 2013 13:45:20 -0500
In-Reply-To: <20131220.133854.672157982782686878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/20/2013 07:38 PM, David Miller wrote:
> From: Norbert van Bolhuis <nvbolhuis@aimvalley.nl>
> Date: Fri, 20 Dec 2013 14:30:06 +0100
>
>>
>> I'm compiling my 32bit application with -m32 on a x86_64
>> system/kernel.
>>
>> Things aren't working because for my application tp_len is at offset 4
>> but for the kernel it is at offset 8.
>>
>> struct tpacket_hdr {
>>          unsigned long   tp_status;
>>          unsigned int    tp_len;
>>          unsigned int    tp_snaplen;
>>          unsigned short  tp_mac;
>>          unsigned short  tp_net;
>>          unsigned int    tp_sec;
>>          unsigned int    tp_usec;
>> };
>>
>> How is this suppose to work ?
>
> This is why you should use tpacket layout v2 or v3, rather than v1,
> they fix these issues.

Norbert, please also read Documentation/networking/packet_mmap.txt

Thanks !
