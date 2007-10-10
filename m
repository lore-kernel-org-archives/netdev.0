From: "Denys" <denys@visp.net.lb>
Subject: Re: [re] Possible 2.6.22 -> 2.6.23 HTB regression?
Date: Wed, 10 Oct 2007 16:31:13 +0300
Message-ID: <20071010132838.M20565@visp.net.lb>
References: <20071010124510.M18768@visp.net.lb> <470CC97F.4000906@trash.net> <1192021963.4853.21.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca, Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:36917 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547AbXJJNmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 09:42:00 -0400
In-Reply-To: <1192021963.4853.21.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patch applied. Rebooted over kexec to 2.6.23 without nmi_watchdog, for now 
all seems fine.

visp-1 ~ # cat /proc/net/psched
000003e8 00000400 000f4240 3b9aca00

82942/82949 KBit/S (53083445/53087945) (106109614/106105114)
82955/82955 KBit/S (53091631/53091631) (159193059/159193059)
82955/82955 KBit/S (53091351/53091351) (212284690/212284690)
82951/82951 KBit/S (53088902/53088902) (265376041/265376041)
82940/82940 KBit/S (53081605/53081605) (318464943/318464943)
82959/82959 KBit/S (53094269/53094269) (371546548/371546548)
81596/81596 KBit/S (52221918/52221918) (424640817/424640817)
82909/82909 KBit/S (53062055/53062055) (476862735/476862735)
82939/82939 KBit/S (53081402/53081402) (529924790/529924790)
82963/82963 KBit/S (53096554/53096554) (583006192/583006192)
82954/82954 KBit/S (53090871/53090871) (636102746/636102746)
82030/82943 KBit/S (52499816/53084066) (689193617/689193617)
82945/82945 KBit/S (53085182/53085182) (741693433/742277683)
82964/82954 KBit/S (53097002/53091002) (794778615/795362865)



--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

