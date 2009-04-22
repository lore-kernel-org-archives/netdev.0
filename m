From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: What makes a good fake MAC address?
Date: Wed, 22 Apr 2009 13:48:27 -0700
Message-ID: <200904221348.27357.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:30355 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757138AbZDVUs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 16:48:28 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi All

The Intel i2400m WiMAX driver behaves as an ethernet device, and currently 
when sending packets to the netdev stack, it fakes an ethernet header, sets 
the "from" mac address to zeroes and the "to" to it's own MAC address.

The WiMAX network can be considered to be a point-to-point (up to the gateway) 
connection, all IP based, so there are not MAC addresses from our gateway 
(not to mention that it can change behind us).

The problem with using a zero mac address is that it confuses the bridging 
software (and maybe others). I was wondering, what would be a fake mac 
address we could put in there that is legal for this kind of "faking"? [or 
the closest thing to legal?]

Thanks!

-- 
Inaky
