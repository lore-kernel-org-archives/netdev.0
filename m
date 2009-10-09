From: sjur.brandeland@stericsson.com
Subject: [PATCH] [CAIF-RFC 0/8-v2] CAIF Protocol Stack
Date: Fri, 09 Oct 2009 15:39:23 +0200
Message-ID: <1255095571-6501-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: stefano.babic@babic.homelinux.org, randy.dunlap@oracle.com,
	kim.xx.lilliestierna@stericsson.com,
	christian.bejram@stericsson.com, daniel.martensson@stericsson.com,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgo1smout1.broadpark.no ([217.13.4.94]:51694 "EHLO
	bgo1smout1.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758110AbZJINlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 09:41:01 -0400
Received: from bgo1sminn1.broadpark.no ([217.13.4.93])
 by bgo1smout1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KR90021W1Y9VL90@bgo1smout1.broadpark.no> for
 netdev@vger.kernel.org; Fri, 09 Oct 2009 15:39:45 +0200 (CEST)
Received: from localhost.localdomain ([84.49.68.131])
 by bgo1sminn1.broadpark.no
 (Sun Java(tm) System Messaging Server 6.3-3.01 (built Jul 12 2007; 32bit))
 with ESMTP id <0KR900DNY1Y4LSP0@bgo1sminn1.broadpark.no> for
 netdev@vger.kernel.org; Fri, 09 Oct 2009 15:39:45 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Braendeland <sjur.brandeland@stericsson.com>

This is the second version of the CAIF patch set.
The patch set is compiled on 386 for 2.6.31.
All feedback is apreciated.

Change log:
* Minor documentation updates
* Character device chnl_chr.c now supports non-blocking open/close.
* Net device chnl_net.c now support multiple instances.
* Cleanup of create_channel.cnf
* Spelling issues in Kconfig files
* Compilation problems in chardevconfig=20
* Makefile problems compiling Net and Char dev
* Removed obsolete chnl_tty.c
* Removed shared memory physical interface
* Remove #ifdef CAIF_USE_SKB from caif_layer.h
* Changed #include statements all over.


BR/Sjur Br=E6ndeland
