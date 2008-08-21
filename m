From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [RFC] New Qlogic 10Gb Ethernet driver for 2.6.28
Date: Thu, 21 Aug 2008 11:54:02 -0700
Message-ID: <20080821185402.GD31526@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Linux-Driver@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26559 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbYHUSyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 14:54:36 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

Please find our new 10Gb ethernet driver at the following site:

ftp://ftp.qlogic.com/outgoing/linux/network/linux/upstream/qlge

There are two files at this location:
qlge-aug212008.patch - A full patch that is buildable on the latest netdev/upstream kernel.
qlge-aug212008.tar.bz2 - A zip file of the source code at drivers/net/qlge/*

We are targeting this driver for 2.6.28 release.  We look forward to any and all comments.

Notes:
1) The file qlge_mpi.c (Management Port Interface) is mostly stubbed right now but will have functionality to handle setting up wake-on-lan and getting/setting link paramters.
2) Please ignore "#ifdef PALLADIUM".  It will be removed going forward as it's currently used for a test platform.

Regards,
Ron Mercer
Qlogic Corporation
