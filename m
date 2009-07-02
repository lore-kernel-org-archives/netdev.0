From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: Re: [PATCH] bnx2: Fix the behavior of ethtool when ONBOOT=no
Date: Thu, 02 Jul 2009 13:46:55 +0900
Message-ID: <4A4C3BBF.8050005@miraclelinux.com>
References: <1245862760.12000.507.camel@nseg_linux_HP1.broadcom.com>	<4A480FA8.4000401@miraclelinux.com>	<1246373417.1685.3.camel@lb-tlvb-eilong> <20090630.124619.163112912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, mchan@broadcom.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw.miraclelinux.com ([122.216.84.157]:48088 "EHLO
	mailgw.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbZGBErM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 00:47:12 -0400
In-Reply-To: <20090630.124619.163112912.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

I'm sorry for my tactless mail.
I see your comment.

Best Regards,
Naohiro Ooiwa

David Miller wrote:
> From: "Eilon Greenstein" <eilong@broadcom.com>
> Date: Tue, 30 Jun 2009 17:50:16 +0300
> 
>> On Sun, 2009-06-28 at 17:49 -0700, Naohiro Ooiwa wrote:
>>> Hi Michael
>>>
>>> Thank you for your comment.
>>>
>>> I tried to create a patch of bnx2x driver.
>>> It's the same fix as bnx2 driver.
>>> Could you please check the my patch ?
>>>
>>> Of cource, I made sure of compile.
>> It is also working as expected. I already made a similar patch based on
>> your bnx2 fix and it looks exactly the same...
>>
>> Thanks!
>>
>>> Signed-off-by: Naohiro Ooiwa <nooiwa@miraclelinux.com>
>> Acked-by: Eilon Greenstein <eilong@broadcom.com>
> 
> Applied, but you really need to begin writing proper changelog
> entries when you send patches out.  Here is the one I wrote for you
> below.  Otherwise a random person looking at this change will have no
> idea the reason for it, nor what it is related to.
> 
> ==================================================
> bnx2x: Fix the behavior of ethtool when ONBOOT=no
> 
> This is the same fix as commit
> 7959ea254ed18faee41160b1c50b3c9664735967 ("bnx2: Fix the behavior of
> ethtool when ONBOOT=no"), but for bnx2x:
> 
> --------------------
>     When configure in ifcfg-eth* is ONBOOT=no,
>     the behavior of ethtool command is wrong.
>     
>         # grep ONBOOT /etc/sysconfig/network-scripts/ifcfg-eth2
>         ONBOOT=no
>         # ethtool eth2 | tail -n1
>                 Link detected: yes
>     
>     I think "Link detected" should be "no".
> --------------------
> 
> Signed-off-by: Naohiro Ooiwa <nooiwa@miraclelinux.com>
> Acked-by: Eilon Greenstein <eilong@broadcom.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> 

