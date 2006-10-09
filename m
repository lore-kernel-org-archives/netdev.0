From: Jean Delvare <jdelvare@suse.de>
Subject: Exact meaning of rx_bytes and tx_bytes
Date: Mon, 9 Oct 2006 17:39:02 +0200
Message-ID: <200610091739.02361.jdelvare@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from public.id2-vpn.continvity.gns.novell.com ([195.33.99.129]:2492
	"EHLO gwia-smtp.id2.novell.com") by vger.kernel.org with ESMTP
	id S1751889AbWJIPit (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Oct 2006 11:38:49 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I am wondering what exactly the rx_bytes and tx_bytes values exported 
under statistics/ in sysfs are supposed to represent.

Most popular ethernet drivers (8139too, e100, 3c59x) count the bytes in 
software, so they only take into account the bytes they actually send and 
receive. This excludes the 4-byte ethernet CRC if I understand correctly.

Other drivers, on the other hand, get the transfered bytes statistics from 
hardware registers, and these appear to include the 4-byte CRC in the 
total count. This is the case of sk98lin and e1000, for example.

So my question is, which drivers are right? Are we counting the emitted 
and received bytes at software level or at hardware level? Or do we just 
not care about the 4-byte/packet difference and both are acceptable?

Thanks,
-- 
Jean Delvare
Suse L3
