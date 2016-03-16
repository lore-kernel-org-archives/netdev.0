From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Wed, 16 Mar 2016 23:23:59 +0100
Message-ID: <CAGm1_kuMQrECdb6_NpZ83Nm4RFSn6sQMhMK6392PLyaFFxCs1A@mail.gmail.com>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
 <CAGm1_kufFr0SsVwVcABXkL0ABJahiwz4EZ70=ywrtC9Bffbfng@mail.gmail.com> <20160316161848.GE2393@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?B?c2hhb2h1aSDosKI=?= <shh.xie@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, drivshin@allworx.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f46.google.com ([209.85.213.46]:33589 "EHLO
	mail-vk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967095AbcCPWYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 18:24:20 -0400
Received: by mail-vk0-f46.google.com with SMTP id k1so80659591vkb.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 15:24:20 -0700 (PDT)
In-Reply-To: <20160316161848.GE2393@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On Wed, Mar 16, 2016 at 5:18 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Mar 16, 2016 at 04:59:23PM +0100, Yegor Yefremov wrote:
>
>> This patch breaks my am335x based board, where one of the CPSW slaves
>> is connected to IP175D switch chip via RMII interface. Since this
>> patch packet reception is not working.
>
> Hi Yegor
>
> Which phy is causing the problem? A PHY inside the switch?
>
> Do you have two back to back PHYs between the MAC and the switch, or
> is the CPSW RMII connected directly to the switch?

CPSW RMII is connected directly to the switch.

Yegor
