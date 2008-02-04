From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH 0/2] ehea: kdump & memory remove support
Date: Mon, 4 Feb 2008 14:04:25 +0100
Message-ID: <200802041404.26138.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.29.152]:46977 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbYBDNE3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 08:04:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set adds support for kdump and hotplug memory remove
to the eHEA driver.=20

The "memory remove" patch depends on the following patch that
has been posted a few days ago. That patch exports the symbols
=A0- register_memory_notifier()
=A0- unregister_memory_notifier()

http://lkml.org/lkml/2008/2/1/293

Regards,
Jan-Bernd
