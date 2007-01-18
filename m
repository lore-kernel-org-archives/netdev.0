From: Adam Kropelin <akropel1@rochester.rr.com>
Subject: Re: intel 82571EB gigabit fails to see link on 2.6.20-rc5 in-tree e1000 driver (regression)
Date: Wed, 17 Jan 2007 19:04:48 -0500
Message-ID: <20070117190448.A20184@mail.kroptech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allen Parker <parker@isohunt.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-03.nyroc.rr.com ([24.24.2.57]:41380 "EHLO
	ms-smtp-03.nyroc.rr.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbXAQXe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 18:34:56 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Allen Parker wrote:
>> Allen Parker wrote:
>>>  From what I've been able to gather, other Intel Pro/1000 chipsets 
>>> work fine in 2.6.20-rc5. If the e1000 guys need any assistance 
>>> testing, I'll be more than happy to volunteer myself as a guinea pig 
>>> for patches.
>> 
>> I wasn't aware that I was supposed to post this as a regression, so 
>> changed the subject, hoping that someone will pick this up and run with 
>> it. Primary issue being that link is not seen on this chipset under 
>> 2.6.20-rc5 via in-tree e1000 driver, despite multiple cycles of ifconfig 
>> $eth up && ethtool $eth | grep link && ifconfig $eth down. Tested on 2 
>> machines with identical hardware.
>
> I asked Allen to report this here. I'm working on the issue as we speak
> but for now I'll treat the link issue as a known regression once I 
> confirm it. If others have seen it then I'd like to know ASAP of course

I am experiencing the no-link issue on a 82572EI single port copper
PCI-E card. I've only tried 2.6.20-rc5, so I cannot tell if this is a
regression or not yet. Will test older kernel soon.

Can provide details/logs if you want 'em.

--Adam

