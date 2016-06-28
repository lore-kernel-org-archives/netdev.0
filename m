From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: dsa: Platform data for dsa2.c
Date: Mon, 27 Jun 2016 18:19:28 -0700
Message-ID: <CAGVrzcYzJ-NOZ-vTO_zRAVfhQ5qd=06dY9ybHfBwJHV6GtmK8A@mail.gmail.com>
References: <1467075163-15890-1-git-send-email-f.fainelli@gmail.com> <20160628010551.GD26597@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:38145 "EHLO
	mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbcF1BUI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2016 21:20:08 -0400
Received: by mail-it0-f46.google.com with SMTP id h190so3870299ith.1
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2016 18:20:08 -0700 (PDT)
In-Reply-To: <20160628010551.GD26597@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-06-27 18:05 GMT-07:00 Andrew Lunn <andrew@lunn.ch>:
> On Mon, Jun 27, 2016 at 05:52:37PM -0700, Florian Fainelli wrote:
>> Hi all,
>>
>> This patch series adds support for platform data using the new code from
>> net/dsa/dsa2.c. The motivation behind this is that we have a bit of in tree
>> platforms (ar7, bcm47xx, x86, others) that could be benefiting from the new
>> dsa_register_switch() API model but do not support Device Tree, nor is there a
>> plan to bring Device Tree to these platforms (time vs. benefits).
>
> Hi Florian
>
> Please could you convert an in tree device to actually use this.

Sure, I don't think there are going to be in tree users who need the
dsa2_port_link information most of what we have is typically single
chip, and so in that case, we can even re-use the existing
dsa_platform_data.
-- 
Florian
