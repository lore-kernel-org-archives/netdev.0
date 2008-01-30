From: maximilian attems <max@stro.at>
Subject: b44 compile failure
Date: Wed, 30 Jan 2008 11:59:26 +0100
Message-ID: <20080130105926.GC24152@stro.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: zambrano@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:39215 "EHLO
	baikonur.stro.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333AbYA3LAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2008 06:00:04 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 drivers/net/b44.c: In function 'b44_remove_one':
 drivers/net/b44.c:2231: error: implicit declaration of function 'ssb_pcihost_set_power_state'

 compiles fine on 64 bit x86, but not on 32, see log:
 http://stats.buildserver.net/fetch.php?&pkg=linux-2.6&ver=2.6.24-trunk1%7Esnapshot.10272&arch=i386&stamp=1201665377&file=log&as=raw

