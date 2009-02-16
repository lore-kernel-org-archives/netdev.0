From: Santwona.Behera@Sun.COM
Subject: [PATCH 0/3] Add support for RX packet classification in a network
 device
Date: Mon, 16 Feb 2009 09:16:58 -0800
Message-ID: <49999F8A.5090306@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>,
	Santwona Behera <Santwona.Behera@Sun.COM>
To: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org,
	gkernel-commit@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:55917 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbZBPRRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 12:17:21 -0500
Received: from fe-sfbay-09.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n1GHH6B9009706
	for <netdev@vger.kernel.org>; Mon, 16 Feb 2009 09:17:18 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-09.sun.com by fe-sfbay-09.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KF600M004DM3A00@fe-sfbay-09.sun.com> for netdev@vger.kernel.org; Mon,
 16 Feb 2009 08:58:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a set of 3 patches, which is the modified version of the one 
posted on 02/09/09. It incorporates 2 changes:

1. The bulk of the classification code was moved to a new file - 
rxclass.c for the ethtool application source code.

2. The network structures in the classification interface have been 
defined to be in the network byte order and application and driver code 
have been modified to conform to this specification.

Regards,
--santwona

