From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH] net: davinci_mdio: Use of_mdiobus_register()
Date: Tue, 06 May 2014 18:51:38 +0200
Message-ID: <5369131A.1020908@gmail.com>
References: <1399389492-32596-1-git-send-email-zonque@gmail.com> <CAGVrzcYH2BXTQ7bM_usz=ZuiAoU8PfNWVtDsxb6ONBxEimhDgw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm <mugunthanvnm@ti.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:58351 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaEFQvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:51:42 -0400
Received: by mail-ee0-f48.google.com with SMTP id e49so5459488eek.7
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 09:51:40 -0700 (PDT)
In-Reply-To: <CAGVrzcYH2BXTQ7bM_usz=ZuiAoU8PfNWVtDsxb6ONBxEimhDgw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/06/2014 06:42 PM, Florian Fainelli wrote:
> 2014-05-06 8:18 GMT-07:00 Daniel Mack <zonque@gmail.com>:
>> of_mdiobus_register() calls mdiobus_register() internally, so the
>> functionality is preserved. However, by calling the of_ variant, phy
>> nodes can be augmented with extra information.
> 
> Are there any non Device Tree aware platforms using this driver?
> of_mdiobus_register() is an empty stub returning -ENOSYS when
> CONFIG_OF is not set, maybe we should make it return
> mdiobus_register() instead...

Ah, good point. Yes, what you propose seems like a valid fix. I'll send
a patch for that.


Thanks,
Daniel
