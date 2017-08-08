From: Arkadi Sharshevsky <arkadis@mellanox.com>
Subject: Re: Driver profiles RFC
Date: Tue, 8 Aug 2017 18:44:35 +0300
Message-ID: <142bdb6c-6943-4438-bd02-ac293e326967@mellanox.com>
References: <6d8560fa-8346-0c43-272d-d39be65ea82f@mellanox.com>
 <20170808135436.GA2015@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        ivecera@redhat.com, roopa@cumulusnetworks.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        john.fastabend@gmail.com, Jiri Pirko <jiri@resnulli.us>,
        mlxsw <mlxsw@mellanox.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0082.outbound.protection.outlook.com ([104.47.1.82]:51707
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752062AbdHHPoo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 8 Aug 2017 11:44:44 -0400
In-Reply-To: <20170808135436.GA2015@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 08/08/2017 04:54 PM, Andrew Lunn wrote:
> On Tue, Aug 08, 2017 at 04:15:41PM +0300, Arkadi Sharshevsky wrote:
>> Drivers may require driver specific information during the init stage.
>> For example, memory based shared resource which should be segmented for
>> different ASIC processes, such as FDB and LPM lookups.
> 
> Hi Arkadi
> 
> Have you looked around other subsystems to see if they have already
> solved this problem?
> 

One obvious possible solution which other subsystems use is module prams,
which is not acceptable.

> How about GPUs? Do they have a similar requirement?

Seems they are using module params. Furthermore, I checked the DRM API
and such a feature is not supported.

> 
> This seems like a generic problem for 'smart' peripherals. How would
> you use dpipe with a GPU for example?
> 
>     Andrew
> 

Thanks for the review.
Arkadi
