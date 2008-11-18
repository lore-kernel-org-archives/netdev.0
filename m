From: Giulio Benetti <giulio.benetti@micronovasrl.com>
Subject: Re: macb phy address bug?
Date: Tue, 18 Nov 2008 12:54:10 +0100
Message-ID: <gfuad2$907$1@ger.gmane.org>
References: <20081116.015050.238612963.davem@davemloft.net> <492281C9.6060006@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7Bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:39015 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbYKROaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 09:30:07 -0500
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1L2Rac-0007fZ-Ga
	for netdev@vger.kernel.org; Tue, 18 Nov 2008 14:30:02 +0000
Received: from 88.62.46.0 ([88.62.46.0])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 14:30:02 +0000
Received: from giulio.benetti by 88.62.46.0 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2008 14:30:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Giuseppe CAVALLARO wrote:

> In my opinion, we need to rework this patch again for two reasons:
> 1) it doesn't cover the case when the PHYID is 0xffffffff.
> 2) we need to add an explicit comment on the PHYID check to highlight that
>     this is a  work-around the broken hardware (in case we get 0xffff or
> 0x0).
> I've also tested it on several PHY devices: e.g. smsc lan 8700, ste101p,
> ste100p,
> DP83865 National GPHY.
> Where, for some of these, we need to treat the phyid=0 as wrong UID.
> Please, review the attached patch.
> 
> Regards,
> Peppe
> 
> David Miller wrote:
>> I've applied this patch to net-2.6, thanks.
>>
>> As mentioned there is some rare chance that the new
>> zero test could cause problems, in which case we'll
>> need to undo that part.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>>

You're right on hardware, it's my fault. The problem is on the primitives of 
mdio from atmel, I will patch them.

Giulio


