From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Wed, 15 Jun 2016 00:26:31 +0300
Message-ID: <fdcc3c47-b060-d5c2-94bf-d9ab70a3cff5@cogentembedded.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
 <57607352.4020900@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:33463 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119AbcFNV0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:26:34 -0400
Received: by mail-lb0-f174.google.com with SMTP id xp5so462320lbb.0
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 14:26:34 -0700 (PDT)
In-Reply-To: <57607352.4020900@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2016 12:12 AM, Jeremy Linton wrote:

>>> If the interrupt configuration isn't set and we are using the
>>
>>     It's never set, judging by the driver code.
>
>     AFAIK, I think that its set when the device is configured as a platform
> device, or there is an external phy/interrupt setup in DT. I might be wrong on
> that..

    I totally fail to see that, even in net-next. The only place that uses 
'phy_irq' is that buggy memcpy()...

MBR, Sergei
