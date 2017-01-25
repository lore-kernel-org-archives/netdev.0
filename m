From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V2 3/3] net: phy: bcm-phy-lib: clean up remaining AUXCTL
 register defines
Date: Wed, 25 Jan 2017 12:35:01 -0800
Message-ID: <4d23e044-e1e6-64da-8481-d1295b1042ff@gmail.com>
References: <20170125200027.14387-1-zajec5@gmail.com>
 <20170125200027.14387-4-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Xo Wang <xow@google.com>, Joel Stanley <joel@jms.id.au>,
        Jon Mason <jon.mason@broadcom.com>,
        Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35980 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752262AbdAYUfD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 15:35:03 -0500
Received: by mail-pg0-f65.google.com with SMTP id 75so20579276pgf.3
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 12:35:03 -0800 (PST)
In-Reply-To: <20170125200027.14387-4-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2017 12:00 PM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> 1) Use 0x%02x format for register number. This follows some other
>    defines and makes it easier to distinct register from values.
> 2) Put register define above values and sort the values. It makes
>    reading header code easier.
> 3) Use 0x%04x format for all values. It's about consistency with other
>    values (and most of the header) not a personal preference.
> 4) Separate define for reading shift value with an extre empty line.
>    It's user for all AUXCTL registers in a bcm54xx_auxctl_read.
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
-- 
Florian
