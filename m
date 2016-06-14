From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 23:44:26 +0300
Message-ID: <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f50.google.com ([209.85.215.50]:35825 "EHLO
	mail-lf0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbcFNUoa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 16:44:30 -0400
Received: by mail-lf0-f50.google.com with SMTP id u74so1208243lff.2
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 13:44:29 -0700 (PDT)
In-Reply-To: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 07:16 PM, Jeremy Linton wrote:

> If the interrupt configuration isn't set and we are using the

    It's never set, judging by the driver code.

> internal phy, then we need to poll the phy to reliably detect
> phy state changes.

    What address your internal PHY is at? Mine is at 1, and things seem to 
work reliably after probing:

SMSC LAN8700 18000000.etherne:01: attached PHY driver [SMSC LAN8700]
(mii_bus:phy_addr=18000000.etherne:01, irq=-1)

    I'm using the device tree on my board.

MBR, Sergei
