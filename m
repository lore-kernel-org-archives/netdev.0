From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Fix DMA channel misreporting for the Renesas
 Ethernet drivers
Date: Mon, 18 Jul 2016 12:57:33 -0700 (PDT)
Message-ID: <20160718.125733.1494576785457064943.davem@davemloft.net>
References: <8592210.gMERdmUlCp@wasted.cogentembedded.com>
	<20160717.232451.295029329698830463.davem@davemloft.net>
	<3244a329-1b48-4e09-7fe5-96d80b8a3d54@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <3244a329-1b48-4e09-7fe5-96d80b8a3d54@cogentembedded.com>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 18 Jul 2016 17:13:02 +0300

> Hello.
> 
> On 07/18/2016 09:24 AM, David Miller wrote:
> 
>>>    Here's a set of 2 patches against DaveM's 'net.git' repo fixing
>>> up the DMA channel reporting by 'ifconfig'...
>>
>> Is some fixing some ifconfig output that is effectively meaningless
>> appropriate for 'net'?
> 
>    I just don't know any more users of SIOCGIFMAP ioctl... ip?
>    It seems to  also be used in net/core/rtnetlink.c...

Who cares who uses it.  The important thing to ask is what in the
world could they do with the value?

DMA masks have no meaning or usage since ISA times.
