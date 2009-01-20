From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/10] Tun fixes and netns migration
Date: Tue, 20 Jan 2009 12:53:53 -0800
Message-ID: <m1y6x5lmvy.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, Max Krasnyansky <maxk@qualcomm.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:56254 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754656AbZAUCpI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 21:45:08 -0500
Received: from mx04.mta.xmission.com ([166.70.13.214])
	by out02.mta.xmission.com with esmtp (Exim 4.62)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5Y-00014r-8t
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:08 -0700
Received: from c-24-130-11-59.hsd1.ca.comcast.net ([24.130.11.59] helo=fess.ebiederm.org)
	by mx04.mta.xmission.com with esmtpsa (TLS-1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.63)
	(envelope-from <ebiederm@xmission.com>)
	id 1LPT5X-00053b-Sp
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 19:45:08 -0700
Received: from fess.ebiederm.org (localhost [127.0.0.1])
	by fess.ebiederm.org (8.14.3/8.14.3/Debian-4) with ESMTP id n0L2j9Yj029093
	for <netdev@vger.kernel.org>; Tue, 20 Jan 2009 18:45:09 -0800
Received: (from eric@localhost)
	by fess.ebiederm.org (8.14.3/8.14.3/Submit) id n0L2j9KE029092
	for netdev@vger.kernel.org; Tue, 20 Jan 2009 18:45:09 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Having a tun device that can be migrated between network namespaces 
is interesting when setting up creative network topologies using
network namespaces.

To get there requires some general clean and restructuring of the
tun driver.

Eric
