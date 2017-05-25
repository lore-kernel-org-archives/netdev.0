From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 3/3] net: sysfs: Document PHY device sysfs
 attributes
Date: Wed, 24 May 2017 17:03:23 -0700
Message-ID: <dcb7ac35-d6da-0d0d-dbcd-99f79473af0f@gmail.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-4-f.fainelli@gmail.com> <20170524201018.GH1788@lunn.ch>
 <00fd6fec-29a2-9a54-085b-95f775610d3b@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34830 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161578AbdEYAD1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 20:03:27 -0400
Received: by mail-qt0-f193.google.com with SMTP id r58so28336629qtb.2
        for <netdev@vger.kernel.org>; Wed, 24 May 2017 17:03:27 -0700 (PDT)
In-Reply-To: <00fd6fec-29a2-9a54-085b-95f775610d3b@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 04:07 PM, Florian Fainelli wrote:
> Hi Andrew,
> 
> On 05/24/2017 01:10 PM, Andrew Lunn wrote:
>>> +What:		/sys/class/mdio_bus/<bus>/<device>/phy_interface
>>> +Date:		February 2014
>>> +KernelVersion:	3.15
>>> +Contact:	netdev@vger.kernel.org
>>> +Description:
>>> +		String value indicating the PHY interface, possible
>>> +		values are in include/linux/phy.h function phy_modes.
>>
>> Hi Florian
>>
>> Does this suggest that these strings should be moved to
>> include/uapi/linux/phy.h?
> 
> Humm, I suppose we could do that, although I am not sure ally sure what
> we would be putting in there (at least for now).

I actually prefer to put the possible values in the sysfs documentation
files instead of in a UAPI header. Will submit a v2.
-- 
Florian
