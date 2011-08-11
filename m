From: hayeswang <hayeswang@realtek.com>
Subject: RE: [linux-firmware v2 1/2] rtl_nic: update firmware forRTL8111E-VL
Date: Thu, 11 Aug 2011 11:41:08 +0800
Message-ID: <9DEF5678E5044F80AEBAD3FE738EA980@realtek.com.tw>
References: <1312978979-1808-1-git-send-email-hayeswang@realtek.com> <1312980860.2591.1267.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <dwmw2@infradead.org>, <romieu@fr.zoreil.com>,
	<netdev@vger.kernel.org>
To: 'Ben Hutchings' <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:33810 "EHLO
	rtits2.realtek.com.tw" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751910Ab1HKDle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 23:41:34 -0400
In-Reply-To: <1312980860.2591.1267.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> -----Original Message-----
> From: Ben Hutchings [mailto:ben@decadent.org.uk] 
> > +File: rtl_nic/rtl8168e-3.fw (Version: rtl8168e-3_0.0.1)
> [...]
> 
> Please don't write the version in yet another way.  It should be:
> 

I just think if someone replaces the firmware with another one, I could check
the firmware through the information without checking the ram data.
For example, someone renames the rtl8168f-1.fw to rtl8168e-3.fw and replaces the
original rtl8168e-3.fw. Through ethtool to show the version of the firmware, I
could know the firmware is invalid. If the version only contain the value 0.0.1,
I must compare the binary file to find out the result.

Do you think it is unnecessary to add this information? I could remove the
relative part if you think so.

> File: rtl_nic/rtl8168e-3.fw
> Version: 0.0.1
> 
> Or, if you insist on duplicating the name in the version:
> 
> File: rtl_nic/rtl8168e-3.fw
> Version: rtl8168e-3_0.0.1
> 
 
Best Regards,
Hayes

