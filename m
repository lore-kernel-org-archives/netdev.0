From: Raju Lakkaraju <Raju.Lakkaraju@microsemi.com>
Subject: Re: [v3,net-next] net: phy: Add Edge-rate driver for Microsemi PHYs.
Date: Wed, 28 Sep 2016 16:42:16 +0530
Message-ID: <20160928111215.GB22063@microsemi.com>
References: <20160927211436.GA11602@lunn.ch>
Reply-To: <Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0056.outbound.protection.outlook.com ([104.47.33.56]:28736
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753329AbcI1L1R (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Sep 2016 07:27:17 -0400
Content-Disposition: inline
In-Reply-To: <20160927211436.GA11602@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

Thank you for review and valuable comments.
I will implement below suggestion and resend for review.

Thanks,
Raju.

On Tue, Sep 27, 2016 at 11:14:36PM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> I just realised the possibly correct binding was starring me in the
> face.
> 
> --------------------------------------------------------------|
> |  3.3V         2.5V            1.8V            1.5V          |
> |-------------------------------------------------------------|
> |-2%            -3%             -5%             -6%           |
> |-------------------------------------------------------------|
> |-4%            -6%             -9%             -14%          |
> |-------------------------------------------------------------|
> |-7%            -10%            -16%            -21%          |
> |-------------------------------------------------------------|
> |-10%           -14%            -23%            -29%          |
> |-------------------------------------------------------------|
> |-17%           -23%            -35%            -42%          |
> |-------------------------------------------------------------|
> |-29%           -37%            -52%            -58%          |
> |-------------------------------------------------------------|
> |-53%           -63%            -76%            -77%          |
> |-------------------------------------------------------------|
> 
> So the binding is:
> 
> vsc8531,vddmac          : The vddmac in mV.
> vsc8531,edge-slowdown   : % the edge should be slowed down relative to
>                           the fastest possible edge time.
> 
> Given those two values, the driver can work out the magic value to put
> into the register that nobody knows the true meaning of.
> 

Accepted.

>      Andrew

---
Raju.
