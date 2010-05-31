From: Meelis Roos <mroos@linux.ee>
Subject: Fore 200 firmware
Date: Mon, 31 May 2010 11:06:31 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1005311058180.2805@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:38502 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751717Ab0EaIcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 04:32:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

commit 9c54004ea717116a10886e254e26502ffb1136e9 (atm: [fore200e] 
convert to use request_firmware()) made the fore driver user 
request_firmware() but also removed the building of firmware image.

So the current state is that drivers/atm contains the C dump of fore 200 
firmware in drivers/atm/fore200e_pca_fw.c but this firmware is not built 
and not installed by make install. It's also not present in 
linux-firware tree/packages so the fore driver can not load its firmware 
from anywhere. I guess this is not the intended outcome.

Should we move the firmware to linux-firmware repository and remove 
drivers/atm/fore200e_pca_fw.c or should we convert and install the 
firmware in kernel build system?

-- 
Meelis Roos (mroos@linux.ee)
