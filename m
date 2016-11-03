From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 17/21] amd-xgbe: Add I2C support for
 determining SFP media types
Date: Thu, 3 Nov 2016 10:01:32 -0500
Message-ID: <1af561af-65e2-8422-1901-d4b1c317ad12@amd.com>
References: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
 <20161103133036.3437.71231.stgit@tlendack-t1.amdoffice.net>
 <20161103142815.GB1768@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0089.outbound.protection.outlook.com ([104.47.41.89]:31969
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752138AbcKCPBk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 3 Nov 2016 11:01:40 -0400
In-Reply-To: <20161103142815.GB1768@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/2016 09:28 AM, Andrew Lunn wrote:
> On Thu, Nov 03, 2016 at 08:30:36AM -0500, Tom Lendacky wrote:
>> Add support to initialize and use the I2C controller within the hardware
>> in order to determine the SFP media type that is installed.
> 
> Hi Tom

Hi Andrew

> 
> Did you see the work Russell King did for phylink?
> 
> https://lwn.net/Articles/667055/
> 
> Rather than doing your own proprietary i2c infrastructure, use the
> standard Linux i2c infrastructure. The SFP modules are then just
> normal i2c devices on a normal i2c bus. The work Russell did can then
> access them, export them to user space, get the PHY modes correctly
> setup, etc.

There are a couple of things about this. Russel's work isn't part of
the kernel yet so I can't make use of it.  Additionally, the I2C device
is integrated into the IP of the network device with register addresses
being offsets of the network device BAR so I'm not sure how I would go
about getting it setup in order to use the i2c infrastructure.

Thanks,
Tom

> 
>        Andrew
> 
