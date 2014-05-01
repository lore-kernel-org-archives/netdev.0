From: "Magnos A. Hammes" <magnos@taghos.com.br>
Subject: Re: [PATCH] drivers/net/ethernet/broadcom/bnx2.c
Date: Thu, 01 May 2014 13:36:36 -0300
Message-ID: <53627814.7090106@taghos.com.br>
References: <5361C29C.5060808@taghos.com.br> <1398922768.3056.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gproxy2-pub.mail.unifiedlayer.com ([69.89.18.3]:53598 "HELO
	gproxy2-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751159AbaEAQgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 12:36:53 -0400
In-Reply-To: <1398922768.3056.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01-05-2014 02:39, Michael Chan wrote:
> On Thu, 2014-05-01 at 00:42 -0300, Magnos A. Hammes wrote:
>> Hello,
>>
>>
>> I have a Dell server with the following Broadcom gigabit network
>> adapter that uses the bnx2 driver:
>>
>>          01:00.0 Ethernet controller: Broadcom Corporation NetXtreme II
>>          BCM5716 Gigabit Ethernet (rev 20)
>>
>> I was using kernel 3.2.57 and 3.13.3, but in both of them I faced some
>> trouble to make the ethernet adapter work, whatever version of this
>> two kernels that I try to boot I get the same error:
>>
>>          Can't load firmware file "bnx2/bnx2-mips-09-6.2.1b.fw"
>>          Direct firmware load failed with error -2
>>
> We no longer put the firmware in the kernel tree, so you need to
> download the firmware from the linux-firmware git tree:
>
> git://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git
>
>
>

Ok, I cloned that git tree and used the firmwares available there, but 
it didn't work with this firmware: bnx2/bnx2-mips-09-6.2.1b.fw sha1sum 
8f11b39a60a4e1dd3774a10218c913f1cb761353

It only works when I change the source code of 
"drivers/net/ethernet/broadcom/bnx2.c" and compile the kernel again, 
making him load this firmware "bnx2/bnx2-mips-09-6.2.1a.fw" instead of 
"bnx2/bnx2-mips-09-6.2.1b.fw".

Magnos A. Hammes
