From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Thu, 6 Jul 2006 21:43:38 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC041BD97@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	"Krzysztof Oledzki" <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:48914 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1750821AbWGGEn6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 00:43:58 -0400
Content-class: urn:content-classes:message
To: hadi@cyberus.ca, "Auke Kok" <auke-jan.h.kok@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Jamal wrote:
> Dell D610:
> hadi@jzny2:~$ sudo lspci | grep -i bcm
> 0000:02:00.0 Ethernet controller: Broadcom Corporation 
> NetXtreme BCM5751
> Gigabit Ethernet PCI Express (rev 01)
> 
This is Broadcom tg3 hardware.  Are we talking about
e1000 or tg3?

Flow control advertisement has always been on by default
on tg3 and it doesn't depend on eeprom settings.  Of course
the link partner's advertisement settings can affect the
final outcome of flow control settings on both ends.

