From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fjes: Do not load fjes driver if system does not
 have extended socket device.
Date: Thu, 09 Mar 2017 17:35:19 -0800 (PST)
Message-ID: <20170309.173519.1406243244628930968.davem@davemloft.net>
References: <7a1a2dbc-99e0-06ba-2261-6e6382937486@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com
To: yasu.isimatu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47536 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750734AbdCJBfV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 20:35:21 -0500
In-Reply-To: <7a1a2dbc-99e0-06ba-2261-6e6382937486@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Date: Wed, 8 Mar 2017 16:05:18 -0500

> The fjes driver is used only by FUJITSU servers and almost of all
> servers in the world never use it. But currently if ACPI PNP0C02
> is defined in the ACPI table, the following message is always shown:
> 
>  "FUJITSU Extended Socket Network Device Driver - version 1.2
>   - Copyright (c) 2015 FUJITSU LIMITED"
> 
> The message makes users confused because there is no reason that
> the message is shown in other vendor servers.
> 
> To avoid the confusion, the patch adds a check that the server
> has a extended socket device or not.
> 
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> CC: Taku Izumi <izumi.taku@jp.fujitsu.com>
> ---
> v2:
> 	- Order local variable declarations from longest to shortest line

This patch does not apply cleanly to the net tree.
