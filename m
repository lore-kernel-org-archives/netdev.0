From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: r8168 is needed to enter P-state: Package State6(pc6)onHaswellhardware
Date: Wed, 8 Oct 2014 02:35:23 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB2526D20@RTITMBSV03.realtek.com.tw>
References: <542B3829.3010108@crashplan.pro>
 <20141005165920.GA21926@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw>
 <20141006221307.GB10936@electric-eye.fr.zoreil.com>
 <0835B3720019904CB8F7AA43166CEEB2526B88@RTITMBSV03.realtek.com.tw>
 <20141007201713.GB4398@zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ceriel Jacobs <linux-ide@crashplan.pro>,
	nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:41060 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751504AbaJHCgX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 22:36:23 -0400
In-Reply-To: <20141007201713.GB4398@zoreil.com>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Francois Romieu [mailto:romieu@fr.zoreil.com] 
> Sent: Wednesday, October 08, 2014 4:17 AM
[...]
> > When enabling the ASPM, it would influence the thrpughput. 
> > It is hard to
> > choose performance or power saving. Therefore, we reserve the config
> > to let the user determines it.
> 
> Mmmm...
> 
> How do Realtek's devices behave if Config{2, 3} + MISC registers are
> configured for ASPM whereas PCI config space registers aren't ?

The feature of the ASPM for the nic would be disabled.
ASPM is enabled when both the internal settings and
the PCI config space registers are enabled.
 
Best Regards,
Hayes
