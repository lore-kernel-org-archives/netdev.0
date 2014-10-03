From: Zhi Li <lznuaa@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: fec: fix build error at m68k platform
Date: Fri, 3 Oct 2014 15:14:53 -0500
Message-ID: <CAHrpEqRQkY-09tcvxuuSHK+KbxMYXH50O7brXCA5B-K3V1S9_Q@mail.gmail.com>
References: <1412362831-59318-1-git-send-email-Frank.Li@freescale.com>
	<CAOMZO5B=cgVT1gr5VJ78x_Aj5ssvrsTOq4t0DrrLK4kz7vNMjQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Frank Li <Frank.Li@freescale.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Duan Fugang-B38611 <b38611@freescale.com>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:33225 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750823AbaJCUOz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 16:14:55 -0400
Received: by mail-lb0-f171.google.com with SMTP id z12so1628905lbi.2
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 13:14:54 -0700 (PDT)
In-Reply-To: <CAOMZO5B=cgVT1gr5VJ78x_Aj5ssvrsTOq4t0DrrLK4kz7vNMjQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 3, 2014 at 3:07 PM, Fabio Estevam <festevam@gmail.com> wrote:
> On Fri, Oct 3, 2014 at 4:00 PM, Frank Li <Frank.Li@freescale.com> wrote:
>> reproduce:
>>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>>   chmod +x ~/bin/make.cross
>>   git checkout 1b7bde6d659d30f171259cc2dfba8e5dab34e735
>>   # save the attached .config to linux build tree
>
> There is no attached config ;-)

It is copy from kbuild report.

Can I change to
config: m68k-m5275evb_defconfig (attached as .config)


>
>>   make.cross ARCH=m68k
>>
>> All error/warnings:
>>
>>    drivers/net/ethernet/freescale/fec_main.c: In function 'fec_enet_rx_queue':
>>>> drivers/net/ethernet/freescale/fec_main.c:1470:3: error: implicit declaration of function 'prefetch' [-Werror=implicit-function-declaration]
>>       prefetch(skb->data - NET_IP_ALIGN);
>>       ^
>>    cc1: some warnings being treated as errors
>>
>> missed included prefetch.h
>>
>> Signed-off-by: Frank Li <Frank.Li@freescale.com>
>
> It seems you missed the Reported-by: kbuild test robot
> <fengguang.wu@intel.com> tag.

Okay I can add it.
