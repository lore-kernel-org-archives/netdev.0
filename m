From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: [PATCH 0/2] [NIU] Two new patches for the niu driver.
Date: Wed, 23 Apr 2008 11:10:06 -0700
Message-ID: <480F7B7E.3060808@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:45575 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752530AbYDWSL4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 14:11:56 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m3NIBtXo022375
	for <netdev@vger.kernel.org>; Wed, 23 Apr 2008 11:11:55 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0JZS00I01HWMSK00@fe-sfbay-10.sun.com>
 (original mail from Matheos.Worku@Sun.COM) for netdev@vger.kernel.org; Wed,
 23 Apr 2008 11:11:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two new patches for the niu driver.

 [PATCH 1/2] Determine the # of ports from the card's VPD data.
Newer Neptune cards need to determine the number of ports per card from 
the card type. This is needed because the NCR registers which reflect 
the contents of the SPROM are not preserved across PCI resets.

[PATCH 2/2] Add support for Neptune FEM/NEM cards used in C10 server blades
The network interface in this configuration comes in two HW parts: The 
FEM which has the 10Gige MAC and the NEM which contains the PHYs. The 
NEM module is hotplug capable.

Regards
Matheos

