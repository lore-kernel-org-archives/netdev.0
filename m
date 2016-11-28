From: "Phil Endecott" <spam_from_netdev@chezphil.org>
Subject: Re: Checking for MDIO phy address 0
Date: Mon, 28 Nov 2016 22:17:46 +0000
Message-ID: <1480371466784@dmwebmail.dmwebmail.chezphil.org>
References: <acbf27e0-48d3-736c-2ff4-69969ced9da7@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; format="flowed"
Cc: <netdev@vger.kernel.org>
To: "Florian Fainelli" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:4724 "EHLO japan.chezphil.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754767AbcK1WRu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 17:17:50 -0500
Received: from localhost ([127.0.0.1] helo=chezphil.org)
        by japan.chezphil.org with esmtp (Exim 4.72)
        (envelope-from <spam_from_netdev@chezphil.org>)
        id 1cBUFA-00084W-El
        for netdev@vger.kernel.org; Mon, 28 Nov 2016 22:17:48 +0000
In-Reply-To: <acbf27e0-48d3-736c-2ff4-69969ced9da7@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Florian,

Florian Fainelli wrote:
> On 11/28/2016 10:53 AM, Phil Endecott wrote:

>> Anyway, my reason for this message is to suggest a runtime diagnostic 
>> message somewhere if address 0 is used - this could have saved me a lot of 
>> work! If someone can suggest the right place to add this I can prepare a 
>> patch.
>
> Address 0 can be made special or not, but there is no programmatic way
> to tell without scanning the MDIO bus for devices, so I don't think a
> warning is going to help at all to warn about that. There are also tons
> of cases where the address is just treated like any other address, which
> is typical with MDIO connected Ethernet switches where PHY@0 is just the
> switch's port 0 built-in PHY for instance.

Thanks for the quick reply; I'll forget that idea.

Regarding the actual problem with the 0 address on this board, I
have been told that someone at APM is going to look into it.  Fingers
crossed that it's fixable somewhere in a driver.  I'll update the list
if necessary.


Cheers,  Phil.
