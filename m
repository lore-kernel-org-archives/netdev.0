From: Rick Jones <rick.jones2@hp.com>
Subject: Should "N/A" dust bunnies be swept from fw_version?
Date: Thu, 17 Nov 2011 15:27:09 -0800
Message-ID: <4EC5984D.5070501@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:17960 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664Ab1KQX1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 18:27:10 -0500
Received: from g1t0039.austin.hp.com (g1t0039.austin.hp.com [16.236.32.45])
	by g1t0027.austin.hp.com (Postfix) with ESMTP id 6CF5838564
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 23:27:10 +0000 (UTC)
Received: from [16.89.64.213] (tardy.cup.hp.com [16.89.64.213])
	by g1t0039.austin.hp.com (Postfix) with ESMTP id 3C45D34091
	for <netdev@vger.kernel.org>; Thu, 17 Nov 2011 23:27:10 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the discussion on "enable virtio_net to return bus_info in ethtool -i 
consistent with emulated NICs" Ben Hutchings had the following feedback 
on what might go into bus_info:

> Please use the existing 'not implemented' value, which is the empty
> string.   If you think ethtool should print some helpful message instead
> of an empty string, please submit a patch for ethtool.

When I was sweeping in the .get_drvinfo routines, I noticed many drivers 
would return "N/A" for fw_version - presumably they were drivers for 
cards without firmware.  Should those be removed to have the fw_version 
be the empty string, or should those sleeping dust bunnies be allowed to 
lie?

rick jones
