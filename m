From: Vladislav Bolkhovitin <vst@vlnb.net>
Subject: Re: r8169 & TX offload
Date: Wed, 17 Oct 2007 21:42:54 +0400
Message-ID: <4716499E.9040701@vlnb.net>
References: <4714D785.3000402@vlnb.net> <20071016172517.GA8120@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-relay-02.mailcluster.net ([77.221.130.214]:36297 "EHLO
	mail-relay-01.mailcluster.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755522AbXJQSJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 14:09:12 -0400
In-Reply-To: <20071016172517.GA8120@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> (please remove l-k from the Cc:, this ought to be sent to netdev)

OK. Sorry, for some reason I thought I read in the MAINTAINERS file that 
LKML is the mailing list for r8169 driver.

> Vladislav Bolkhovitin <vst@vlnb.net> :
> 
>>I've recently bought Realtek RTL8169S-32 chip based Gigabit Ethernet card:
>>
>># lspci -vv
> 
> [...]
> 
>>I've noticed that all TX offload features (tx-checksumming, 
>>scatter-gather and TSO) are disabled by default and should be manually 
>>enabled by ethtool. I wonder, is there any particular reason for that? 
> 
> As far as I can tell, it is mostly a lack of pressure from the users and
> my desire to avoid a change of behavior.
> 
>>Why they are not enabled by default as it was done for e1000 or tg3? Are 
>>there any hidden drawbacks in enabling them?
> 
> None that I know of. I had not noticed a huge difference and people did
> not comment a lot either...

I think, 30% of CPU saving is worth enough to turn TX offload on, 
especially if a system does something more than just data transfers. 
Usually, such options are enabled by default unless there are some 
hidden important drawbacks, like stability issues. Hence, there are 
questions like mine: it's just too suspicious that something good 
doesn't have hidden issues if it isn't enabled by author ;)

Thanks for clarification.

>>Those offload options are definitely work. They give in my setup (32-bit 
>>66MHz PCI, Xeon 1.7GHz CPU, open-iscsi) CPU offload from 75% to 45% and 
>>data write throughput improvement from 55MB/s to 59MB/s.
> 
> ...but your datapoint is welcome.
> 

