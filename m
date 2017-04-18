From: =?UTF-8?Q?C=c3=a9dric_Le_Goater?= <clg@kaod.org>
Subject: Re: [PATCH] net/ncsi: fix checksum validation in response packet
Date: Tue, 18 Apr 2017 08:16:39 +0200
Message-ID: <873115df-2bd0-65f4-22cf-2b92f3142bf2@kaod.org>
References: <1492160197-13816-1-git-send-email-clg@kaod.org>
 <20170417.133619.1515025171498720534.davem@davemloft.net>
 <20170418000600.GA4978@gwshan>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: joel@jms.id.au, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Gavin Shan <gwshan@linux.vnet.ibm.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 8.mo1.mail-out.ovh.net ([178.33.110.239]:46630 "EHLO
        8.mo1.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756128AbdDRIpF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 04:45:05 -0400
Received: from player756.ha.ovh.net (b6.ovh.net [213.186.33.56])
        by mo1.mail-out.ovh.net (Postfix) with ESMTP id B5B6868F92
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 08:16:44 +0200 (CEST)
In-Reply-To: <20170418000600.GA4978@gwshan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2017 02:06 AM, Gavin Shan wrote:
> On Mon, Apr 17, 2017 at 01:36:19PM -0400, David Miller wrote:
>> From: Cédric Le Goater <clg@kaod.org>
>> Date: Fri, 14 Apr 2017 10:56:37 +0200
>>
>>> htonl was used instead of ntohl. Surely a typo.
>>>
>>> Signed-off-by: Cédric Le Goater <clg@kaod.org>
>>
>> I don't think so, "checksum" is of type "u32" thus is in host byte
>> order.  Therefore "htonl()" is correct.
>>
> 
> Yeah, "htonl()" is correct here. "*pchecksum" is in big-endian.
> I want to know how Cédric thinks it's a problem. I guess he might
> encounter the issue on the emulated NCSI channel by QEMU. 

yes exactly. my bad. After a second look this is correct. Sorry for
the noise. 

> On BCM5718 or BCM5719, the checksum in AEN and response packet 
> are zero'd, meaning the software shouldn't validate it at all.

Interesting.

Thanks,

C.
