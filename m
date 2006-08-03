From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: bonding questions: carrier based link monitoring / slave device
 state flags
Date: Thu, 3 Aug 2006 08:59:31 +0300 (IDT)
Message-ID: <Pine.LNX.4.64.0608030815270.32510@zuben>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:7385 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1751379AbWHCF7d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 01:59:33 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First, i'd like to verify what is the parameter setting to have the
bonding driver use netif_carrier_ok(slave_device) as the means for
link detection. Is setting use_carrier = 1 enough or one needs to set
miimon to non-zero as well??? (where the value of miimon translates
to the link monitoring frequency).

Second, I understand that an enslaved device must **not** be UP, so
when enslaving a device the bonding driver calls dev_open(slave_device),
and make sure the device is UP, correct?

What i want to better understand here, is whether for the bonding driver
to declare a slave as "being able to carry traffic" it assumes the slave
will move from UP to RUNNING state (and later netif_carrier_ok would
return TRUE) without an IP address being set for the slave device ???

Is (per the bonding driver) the **time** it should take the slave to get
from UP to (RUNNING && carrier_ok) state limited and/or controlled?

Or.

