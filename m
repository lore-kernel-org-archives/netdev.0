From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 00/11] net: bcmgenet: PM and Wake-on-LAN
Date: Tue, 22 Jul 2014 13:29:37 -0700
Message-ID: <CAGVrzcbjA5mvQdoCMdaa8HixKLQ5zOBWpDuoL7Zjzguqj6rpwA@mail.gmail.com>
References: <1405981769-24618-1-git-send-email-f.fainelli@gmail.com> <20140722202020.GA13637@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:62668 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460AbaGVUaS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 16:30:18 -0400
Received: by mail-oa0-f50.google.com with SMTP id g18so306327oah.23
        for <netdev@vger.kernel.org>; Tue, 22 Jul 2014 13:30:17 -0700 (PDT)
In-Reply-To: <20140722202020.GA13637@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2014-07-22 13:20 GMT-07:00 Francois Romieu <romieu@fr.zoreil.com>:
> Florian Fainelli <f.fainelli@gmail.com> :
> [...]
>> This patchset brings S2/S3 Power Management support to the GENET driver
>> as well as Wake-on-LAN using Magic Packets with or without SecureOn
>> passwords.
>
> Out of curiosity, do you have a plan to support runtime power suspend,
> say through phy_driver.link_change_notify ?

The internal PHY (drivers/net/phy/bcm7xxx.c) used in conjunction with
the GENET or SYSTEMPORT adapters features auto-power down on link
down, which is where we get most of the power savings.

The remaining digital logic is not too power hungry, but I like your
idea, and will do some testing whether we can save some more power.

Thanks!
-- 
Florian
