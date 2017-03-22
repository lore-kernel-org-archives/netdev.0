From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/2] fjes: Do not load fjes driver
Date: Wed, 22 Mar 2017 12:39:04 -0700 (PDT)
Message-ID: <20170322.123904.2127246481524648740.davem@davemloft.net>
References: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, izumi.taku@jp.fujitsu.com
To: yasu.isimatu@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43706 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759313AbdCVTkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 15:40:06 -0400
In-Reply-To: <c0bb31ae-1f5b-9b73-ed51-a8d56361ff59@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>
Date: Tue, 21 Mar 2017 11:28:02 -0400

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
> To avoid the confusion, the patch adds several checks.
> 
> v3:
>   - Rebase on latest net tree.
>   - Add _STA method check to avoid loading fjes driver.
> 
> v2:
>   - Order local variable declarations from longest to shortest line

Series applied, thanks.
