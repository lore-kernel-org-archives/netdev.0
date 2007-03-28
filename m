From: Patrick McHardy <kaber@trash.net>
Subject: KERNEL: assertion ((int)tp->sacked_out >= 0) failed at net/ipv4/tcp_input.c
 (2626)
Date: Wed, 28 Mar 2007 14:03:20 +0200
Message-ID: <460A5988.2050403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49215 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934274AbXC1L4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 07:56:35 -0400
Received: from [192.168.0.100] (unknown [195.158.167.166])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id 31990948D4
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 13:56:34 +0200 (MEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I got this warning with the current net-2.6.22 tree:

KERNEL: assertion ((int)tp->sacked_out >= 0) failed at
net/ipv4/tcp_input.c (2626)
Leak s=4294967292 3

Can't say what exactly triggered it.
