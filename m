From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: meth: Add set_rx_mode hook to fix ICMPv6 neighbor
 discovery
Date: Tue, 27 Dec 2011 13:52:09 -0500 (EST)
Message-ID: <20111227.135209.1552228715466981902.davem@davemloft.net>
References: <4EED3A3D.9080503@gentoo.org>
        <4EF95247.7000403@gentoo.org>
        <20111227103408.01aad10e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kumba@gentoo.org, netdev@vger.kernel.org, linux-mips@linux-mips.org
To: shemminger@vyatta.com
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20111227103408.01aad10e@nehalam.linuxnetplumber.net>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 27 Dec 2011 10:34:08 -0800

> On Tue, 27 Dec 2011 00:06:15 -0500
> Joshua Kinard <kumba@gentoo.org> wrote:
> 
>> @@ -95,7 +95,7 @@ struct mace_video {
>>   * Ethernet interface
>>   */
>>  struct mace_ethernet {
>> -	volatile unsigned long mac_ctrl;
>> +	volatile u64 mac_ctrl;
>>  	volatile unsigned long int_stat;
>>  	volatile unsigned long dma_ctrl;
>>  	volatile unsigned long timer;
> 
> 
> This device driver writer needs to read:
>   Documentation/volatile-considered-harmful.txt

This driver has a lot of problems, some of which I've made Joshua aware of
already.
