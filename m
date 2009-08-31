From: Michal Simek <michal.simek@petalogix.com>
Subject: Re: [PATCH] [V3] net: add Xilinx emac lite device driver
Date: Mon, 31 Aug 2009 15:18:44 +0200
Message-ID: <4A9BCDB4.8040406@petalogix.com>
References: <20090820094956.02DFC45004F@mail96-dub.bigfish.com> <20090820.025226.26907868.davem@davemloft.net>
Reply-To: michal.simek@petalogix.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: john.linn@xilinx.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com,
	grant.likely@secretlab.ca, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, sadanan@xilinx.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f188.google.com ([209.85.211.188]:46271 "EHLO
	mail-yw0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbZHaNSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 09:18:52 -0400
Received: by ywh26 with SMTP id 26so6016869ywh.5
        for <netdev@vger.kernel.org>; Mon, 31 Aug 2009 06:18:54 -0700 (PDT)
In-Reply-To: <20090820.025226.26907868.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

I see that John's patch has wrong file permission
-rwxr-xr-x 	xilinx_emaclite.c
<http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=blob;f=drivers/net/xilinx_emaclite.c;h=7e05b40ae36b50b6eb66d9512ae3a49ba2d36a47;hb=a9a8cb1d6594037fbb23f1ce45964ec6a3b38215>
	blob
<http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=blob;f=drivers/net/xilinx_emaclite.c;h=7e05b40ae36b50b6eb66d9512ae3a49ba2d36a47;hb=a9a8cb1d6594037fbb23f1ce45964ec6a3b38215>
| history
<http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=history;f=drivers/net/xilinx_emaclite.c;h=7e05b40ae36b50b6eb66d9512ae3a49ba2d36a47;hb=a9a8cb1d6594037fbb23f1ce45964ec6a3b38215>
| raw
<http://git.kernel.org/?p=linux/kernel/git/sfr/linux-next.git;a=blob_plain;f=drivers/net/xilinx_emaclite.c;hb=a9a8cb1d6594037fbb23f1ce45964ec6a3b38215>



should be 644.

Please fix it in your repo.

Thanks,
Michal

> From: John Linn <john.linn@xilinx.com>
> Date: Thu, 20 Aug 2009 03:49:51 -0600
>
>   
>> This patch adds support for the Xilinx Ethernet Lite device.  The
>> soft logic core from Xilinx is typically used on Virtex and Spartan
>> designs attached to either a PowerPC or a Microblaze processor.
>>
>> Signed-off-by: Sadanand M <sadanan@xilinx.com>
>> Signed-off-by: John Linn <john.linn@xilinx.com>
>>     
>
> Applied, thanks.
>   


-- 
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-30090663

