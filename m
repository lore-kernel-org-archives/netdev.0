From: Frank Li <lznuaa@gmail.com>
Subject: Re: Lower wake up time when phy enter lower mode
Date: Thu, 8 Nov 2012 10:09:11 +0800
Message-ID: <CAHrpEqQYXxADPrYd=TwqEPaecWt_yjgkivCR6iek9qk0z73WzQ@mail.gmail.com>
References: <CAHrpEqSw8N4nN6Wgnu2z3tWS_CrGoPMbFj2wJjmDv2JPLW7cLg@mail.gmail.com>
	<1352315183.2725.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Richard Cochran <richardcochran@gmail.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:33248 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752935Ab2KHCJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 21:09:12 -0500
Received: by mail-ie0-f174.google.com with SMTP id k13so3489377iea.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 18:09:11 -0800 (PST)
In-Reply-To: <1352315183.2725.17.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/11/8 Ben Hutchings <bhutchings@solarflare.com>:
> On Wed, 2012-11-07 at 10:52 +0800, Frank Li wrote:
>> Richard:
>>
>>           Recently, I found out the path delay will increase about
>> 20us suddenly in something when connect two iMX6 board and Ethernet
>> work on 1G mode.
>>           The reason is that the PHY enter lower mode automatically
>> when no package send and receive. It takes some time to recover and
>> send out package by PHY but MAC think package have sent and sample
>> time stamper.
>>           Do you meet such case?  I can workaround it by two method
>>                1. disable phy lower power feature.
>>                2. add some dummy package before SYNC package.
>
> If this low power mode is related to EEE (Energy Efficient Ethernet)
> then there are ethtool operations defined for configuring it, and you
> could implement those.

Yes, it is phy specific, called smart EEE, which compatible with IEEE 802.3az
and can be used in legacy MAC without EEE.

Do you have example about ethtool operations?

>
> Ben.
>
> --
> Ben Hutchings, Staff Engineer, Solarflare
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
