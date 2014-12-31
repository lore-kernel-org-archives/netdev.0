From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next v1 0/3] net: fec: add Wake-on-LAN support
Date: Wed, 31 Dec 2014 17:03:28 -0200
Message-ID: <CAOMZO5BFbL-J2gM_T0jD3N3P9wHguaNLENE24BRaMQT7E6Lhiw@mail.gmail.com>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
	<20141231.130727.1660985956287926494.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Duan Fugang-B38611 <b38611@freescale.com>,
	Shawn Guo <shawn.guo@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:53044 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaLaTDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 14:03:30 -0500
Received: by mail-la0-f41.google.com with SMTP id hv19so14266753lab.28
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 11:03:28 -0800 (PST)
In-Reply-To: <20141231.130727.1660985956287926494.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fugang,

Just a minor comment about your patches:

On Wed, Dec 31, 2014 at 4:07 PM, David Miller <davem@davemloft.net> wrote:
> From: Fugang Duan <b38611@freescale.com>

Here we see the From field as Fugang Duan.

> Date: Wed, 24 Dec 2014 17:30:38 +0800
>
>> The patch series enable FEC Wake-on-LAN feature for i.MX6q/dl and i.MX6SX SOCs.
>> FEC HW support sleep mode, when system in suspend status with FEC all clock gate
>> off, magic packet can wake up system. For different SOCs, there have special SOC
>> GPR register to let FEC enter sleep mode or exit sleep mode, add these to platform
>> callback for driver' call.
>>
>> Patch#1: add WOL interface supports.
>> Patch#2: add SOC special sleep of/off operations for driver's sleep callback.
>> Patch#3: add magic pattern support for devicetree.
>
> Series applied, thanks.

,but when we see your patches applied they appear with Nimrod Andy as
the author instead:
https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=de40ed31b3c577cefd7b54972365a272ecbe9dd6

It would be nice if you could use the From field to match the name in
the Signed-off tag.

Regards,

Fabio Estevam
