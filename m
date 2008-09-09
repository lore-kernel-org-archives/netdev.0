From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 0/3] enic: Cisco 10G Ethernet driver
Date: Mon, 8 Sep 2008 20:56:42 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809082041020.18196@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuova-ex1.nuovasystems.com ([67.91.200.196]:7040 "EHLO
	nuova-ex1.nuovasystems.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752304AbYIID5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2008 23:57:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

This patch set adds the Cisco 10G Ethernet driver.  Please consider for 
merging.

Modified according to Roland's suggestions:

 	* depend on INET since we're selecting INIT_LRO
 	* checkpatch.pl clean
 	* sparse -D__CHECK_ENDIAN__ clean
 	* remove LLTX support
 	* use PCI_VDEVICE
 	* use round_jiffies
 	* use rmb() instead of volatile
 	* remove unused funcs

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
