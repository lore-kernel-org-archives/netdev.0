From: Gal Pressman <galp.dev@gmail.com>
Subject: Re: [PATCH RFC 0/2] ethtool: Add actual port speed reporting
Date: Thu, 3 Nov 2016 18:59:11 +0200
Message-ID: <7a681afa-a5fa-3039-873c-d13617484cc9@gmail.com>
References: <1478100914-23610-1-git-send-email-galp@mellanox.com>
 <BL2PR07MB23069B0DB17B981AA43775B18DA00@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: David Decotigny <decot@googlers.com>,
        Ben Hutchings <ben@decadent.org.uk>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        Gal Pressman <galp@mellanox.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "John W. Linville" <linville@tuxdriver.com>,
        Vidya Sagar Ravipati <vidya@cumulusnetworks.com>,
        Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:32990 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbcKCQ7P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 12:59:15 -0400
Received: by mail-wm0-f67.google.com with SMTP id u144so8963170wmu.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 09:59:14 -0700 (PDT)
In-Reply-To: <BL2PR07MB23069B0DB17B981AA43775B18DA00@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/11/2016 17:50, Mintz, Yuval wrote:
>> Sending RFC to get feedback for the following ethtool proposal:
>>
>> In some cases such as virtual machines and multi functions (SR-IOV), the actual
>> bandwidth exposed for each machine is not accurately shown in ethtool.
>> Currently ethtool shows only physical port link speed.
>> In our case we would like to show the virtual port operational link speed which
>> in some cases is less than the physical port speed.
>>
>> This will give users better visibility for the actual speed running on their device.
>>
>> $ ethtool ens6
>> ...
>> Speed: 50000Mb/s
>> Actual speed: 25000Mb/s
> 
> Not saying this is a bad thing, but where exactly is it listed that ethtool has
> to show the physical port speed?
> E.g., bnx2x shows the logical speed instead, and has been doing that for years.
> [Perhaps that's a past wrongness, but that's how it goes].
> 
> And besides, one can argue that in the SR-IOV scenario the VF has no business
> knowing the physical port speed.
> 

Good point, but there are more use-cases we should consider.
For example, when using Multi-Host/Flex-10/Multi-PF each PF should
be able to query both physical port speed and actual speed.
