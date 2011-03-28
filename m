From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: [PATCH 0/2] solos-pci: debugging fixes
Date: Sun, 27 Mar 2011 23:55:19 -0700
Message-ID: <4D9030D7.9080806@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>,
	Nathan Williams <nathan@traverse.com.au>,
	Karl Hiramoto <karl@hiramoto.org>
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:60918 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750776Ab1C1G6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Mar 2011 02:58:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Prindeville <philipp@redfish-solutions.com>

Two patches for net-2.6 HEAD:

The first changes the one remaining instance where the VCI (virtual circuit identifier) is output before the VPI (virtual path identifier).  Standard notation is VPI *then* VCI, and this is used everywhere else.

The second does a "pull" on the sk_buff to remove the "struct pkt_hdr" that prefaces the actual ATM frame data (and includes message type, message size, and VPI/VCI tuple). Logging is the last thing done before releasing the sk_buff, so the header can safely be pulled up at this point.  Also, we alternate between using the term "device" and "port" in the driver, which is inconsistent and confusing. So we also change the term "device" to "port".


