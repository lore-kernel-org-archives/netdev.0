From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: 2.6.29-rc5-git3 Leak r=1 3
Date: Thu, 19 Feb 2009 23:04:35 +0200
Message-ID: <200902192304.35547.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:51223 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbZBSVEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2009 16:04:45 -0500
Received: from hq.army.gov.lb (hq.army.gov.lb [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id 8FEC31A4B09
	for <netdev@vger.kernel.org>; Thu, 19 Feb 2009 23:04:36 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If it is interesting for anybody, on loaded proxy server, at beginning:

[   21.587816] netconsole: remote ethernet address 00:04:23:af:02:ca
[   21.591028] console [netcon0] enabled
[   21.591486] netconsole: network logging started
[   23.942232] sd 11:0:0:0: [sda] 1146040320 512-byte hardware sectors: (586 
GB/546 GiB)
[   23.943077] sd 11:0:0:0: [sda] Write Protect is off
[   23.943138] sd 11:0:0:0: [sda] Mode Sense: 06 00 10 00
[   23.943182] sd 11:0:0:0: [sda] Write cache: enabled, read cache: enabled, 
supports DPO and FUA
[  239.315726] Leak r=1 3
[  306.969147] device eth0 entered promiscuous mode
[  307.941261] device eth0 left promiscuous mode
[  313.606330] device eth0 entered promiscuous mode
[  314.886391] device eth0 left promiscuous mode
