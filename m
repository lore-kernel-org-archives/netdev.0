From: Christian Engelmayer <christian.engelmayer@frequentis.com>
Subject: [RFC] CPSW: dual standalone emac mode / bonding
Date: Wed, 5 Mar 2014 18:33:18 +0100
Message-ID: <20140305183318.16f5dafa@frequentis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.frequentis.com ([195.20.158.50]:20742 "EHLO
	mail1.frequentis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbaCERnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 12:43:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Has anybody successfuly setup ethernet bonding on a TI AM335x based system using
the CPSW in dual standalone emac mode?

I am running an active-backup test setup - momentarily still running Linux 3.2 -
and experience repeated loss of ethernet connectivity. That happens eg. after
the board is idle and receives an own ARP request on the backup slave interface.
It seems that the corresponding reply does not reach the CPU and I can see via
SysFs that the host's address entry got associated with the external backup port.

   index 2, raw: 00000000 10000018 31e00669, type: addr(1), addr: 00:18:31:e0:06:69,
      uctype: persistant(0), port: 0 --> uctype: persistant(0), port: 2

As expected, triggering a unicast from the board or bypassing the ALE recovers
the situation.

Regards,
Christian
