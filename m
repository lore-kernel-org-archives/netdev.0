From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: if_arp.h missing in iproute2
Date: Wed, 26 Aug 2009 18:07:27 +0200
Message-ID: <4A955DBF.60006@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:13014 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbZHZQHa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 12:07:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen,

while compiling the latest iproute2 git with an embedded BSP that had standard
includes from 2.6.23, it complained about a missing APRHRD_CAN definition.

The BSP compiles a 2.6.27.8 Kernel but obviously does not use it's includes.

Adding a recent if_arp.h to iproute2/include/linux/ fixed the problem.

Is there any reason, why if_arp.h is not in the iproute2 git while all the
other relevant stuff can be found there?

Regards,
Oliver
