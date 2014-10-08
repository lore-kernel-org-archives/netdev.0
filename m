From: Ceriel Jacobs <linux-ide@crashplan.pro>
Subject: Re: r8168 is needed to enter P-state: Package State6(pc6)onHaswellhardware
Date: Wed, 08 Oct 2014 13:40:33 +0200
Message-ID: <543522B1.30303@crashplan.pro>
References: <542B3829.3010108@crashplan.pro> <20141005165920.GA21926@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526932@RTITMBSV03.realtek.com.tw> <20141006221307.GB10936@electric-eye.fr.zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526B88@RTITMBSV03.realtek.com.tw> <20141007201713.GB4398@zoreil.com> <0835B3720019904CB8F7AA43166CEEB2526D20@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd <nic_swsd@realtek.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:43642 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933156AbaJHLkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 07:40:39 -0400
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB2526D20@RTITMBSV03.realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hayes Wang schreef op 08-10-14 om 04:35:
>   Francois Romieu [mailto:romieu@fr.zoreil.com]
>> Sent: Wednesday, October 08, 2014 4:17 AM
> [...]
>>> When enabling the ASPM, it would influence the thrpughput.
>>> It is hard to
>>> choose performance or power saving. Therefore, we reserve the config
>>> to let the user determines it.
>>
>> Mmmm...
>>
>> How do Realtek's devices behave if Config{2, 3} + MISC registers are
>> configured for ASPM whereas PCI config space registers aren't ?
>
> The feature of the ASPM for the nic would be disabled.
> ASPM is enabled when both the internal settings and
> the PCI config space registers are enabled.

Have in mind a situation where the PCI config space registers are set 
manually (after user login).

At which point in time will be determined whether ASPM for the nic will 
be disabled or enabled? Once, when loading the kernel module? Or more often?
