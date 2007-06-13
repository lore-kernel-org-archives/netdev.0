From: Peter Rasmussen <plr@udgaard.com>
Subject: Re: IC Plus Corp IC Plus IP1000
Date: Wed, 13 Jun 2007 23:16:10 +0200
Message-ID: <46705E9A.9060903@udgaard.com>
References: <46599FB9.602@udgaard.com> <466F548E.9010807@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-10; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213.237.80.42.adsl.he.worldonline.dk ([213.237.80.42]:19785
	"EHLO kultorvet.udgaard.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751579AbXFMUqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 16:46:48 -0400
In-Reply-To: <466F548E.9010807@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for your suggestion.

I do however, have the following issues, which is also why I searched 
Google for help on it.

1.The Sundance driver is in the 100mbit section, implying that it won't 
work with 1gbit.
2.When I first started up the server I am using with the ethernet 
device, it didn't detect it, even with the Sundance driver compiled in 
to the kernel, so I gave up on it.
3.Now I would like to extend the server with another ethernet device, 
and I would prefer to use what is already installed instead of having to 
buy another additonal ethernet board.
4.While searching for the driver code with Google, it seemed that 
several people would like to see a IC Plus Corp IC Plus IP1000 driver in 
the kernel, and nowhere did I see that using the present Sundance driver 
was adequate.
5.I am not able to reboot this server too often (it is a live web 
server) so I would like to prepare as much as possible before rebooting it.

So, does your suggestion include:

1.The possibility to use the device in gigabit mode?
2.How to tweak the present Sundance driver to better detect a "IC Plus 
Corp IC Plus IP1000" board?
3.Or *is* the Sundance driver supposed to be a generic driver for all 
their boards, including >100mbit?

If you can tell me about that, or give me pointers to figure it out, I'd 
be much obliged!

Thanks,
Peter

Jeff Garzik wrote:
> Peter Rasmussen wrote:
>> I am not on this list, but found this address on:   
>> http://linux-net.osdl.org/index.php/Mailing_Lists.
>>
>> My question is regarding the ethernet controller (from lspci):
>>
>> Sundance Technology Inc / IC Plus Corp IC Plus IP1000 Family Gigabit 
>> Ethernet (rev 41)
>>
>> that seems to have a driver for it published on:
>>
>> http://www.icplus.com.tw/driver-pp-IP1000A.html
>>
>> Unfortunately I am not able to build it as described.
>>
>> I wonder if it at some time will be included in the standard Linux 
>> kernel?
>> I am of course interested because my main board has it built in, so I 
>> would be willing to test it.
>
> Use the 'sundance' driver that's been in the kernel for quite a while.
>
>     Jeff
>
>
