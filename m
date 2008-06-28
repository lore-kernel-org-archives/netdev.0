From: Santwona Behera <Santwona.Behera@Sun.COM>
Subject: [PATCH 0/3] Add support for rx flow hash configuration in a network
 device
Date: Fri, 27 Jun 2008 17:06:16 -0700
Message-ID: <48658078.8030707@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: Matheos.Worku@Sun.COM, Michael.Speer@Sun.COM,
	gkernel-commit@lists.sourceforge.net, Santwona.Behera@Sun.COM
To: netdev@vger.kernel.org, davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:44607 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbYF1AGS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2008 20:06:18 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id m5S06H04017707
	for <netdev@vger.kernel.org>; Fri, 27 Jun 2008 17:06:17 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java System Messaging Server 6.2-8.04 (built Feb 28 2007))
 id <0K3500E01CAB0V00@fe-sfbay-10.sun.com>
 (original mail from Santwona.Behera@Sun.COM) for netdev@vger.kernel.org; Fri,
 27 Jun 2008 17:06:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added new interface to ethtool to configure receive network flow 
classification. This patch adds support for flow distribution using 
hashing where the device can be configured with the fields in the 
receive packet to hash onto one of the multiple Rx rings.

This feature has 3 related patches:

1. An ethtool application patch.
2. A kernel patch for the ethtool interface.
3. A kernel patch for the niu driver that implements the ethtool config 
ioctl functions. NOTE: The niu driver already has rx flow hashing 
implemented. With these 3 patches, this feature is now configurable 
using ethtool.

Thanks!

--santwona
