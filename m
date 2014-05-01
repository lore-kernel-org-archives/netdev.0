From: "Magnos A. Hammes" <magnos@taghos.com.br>
Subject: Re: [PATCH] drivers/net/ethernet/broadcom/bnx2.c
Date: Thu, 01 May 2014 15:49:54 -0300
Message-ID: <53629752.6030606@taghos.com.br>
References: <5361C29C.5060808@taghos.com.br>	 <1398922768.3056.4.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>	 <53627814.7090106@taghos.com.br> <1398965975.3056.40.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"desenvolvimento@taghos.com.br" <desenvolvimento@taghos.com.br>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gproxy4-pub.mail.unifiedlayer.com ([69.89.23.142]:52252 "HELO
	gproxy4-pub.mail.unifiedlayer.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751881AbaEASuR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 May 2014 14:50:17 -0400
In-Reply-To: <1398965975.3056.40.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01-05-2014 14:39, Michael Chan wrote:
> On Thu, 2014-05-01 at 13:36 -0300, Magnos A. Hammes wrote:
>> Ok, I cloned that git tree and used the firmwares available there, but
>> it didn't work with this firmware: bnx2/bnx2-mips-09-6.2.1b.fw sha1sum
>> 8f11b39a60a4e1dd3774a10218c913f1cb761353
>>
>
> I have the same sha1 sum on the same firmware file on my system and it
> works for me.
>
>> It only works when I change the source code of
>> "drivers/net/ethernet/broadcom/bnx2.c" and compile the kernel again,
>> making him load this firmware "bnx2/bnx2-mips-09-6.2.1a.fw" instead of
>> "bnx2/bnx2-mips-09-6.2.1b.fw".
>
> I don't see why it wouldn't work if both firmware files are in the same
> location.  May be you have some udev rules that are preventing it?
>>
>>
>
>

Yes, I have some udev rules that run at system boot, but the only thing 
I do is:

/sbin/udevd --daemon
/sbin/udevadm trigger --type=subsystems --action=add
/sbin/udevadm trigger --type=devices --action=add
/sbin/udevadm settle

Udev runs normally and returns no errors or warnings and dmesg shows 
nothing weird.

So, you think this may be a problem with my udev rules or a udev bug?

I'm using udev version 182.
