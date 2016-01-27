From: Samsonov Dmitry <dmitry.samsonov@corp.mail.ru>
Subject: 802.11ad symmetry
Date: Wed, 27 Jan 2016 10:33:41 +0000
Message-ID: <04BDB9B17E30314988B0D24726BF7DEA3BD9FED1@R2EMBS1.mail.msk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odnoklassniki.ru ([89.111.19.141]:56660 "EHLO
	mail2.odnoklassniki.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbcA0Kdq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 05:33:46 -0500
Received: from email.forticom.com (unknown [172.19.0.56])
	by mail2.odnoklassniki.ru (Postfix) with ESMTP id 3D045820346
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2016 12:33:43 +0200 (EET)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!
bonding-devel@lists.sourceforge.net is not accepting e-mails, so I assume this list is the correct destination.
Is there a way to make LACP bonding between a linux box and a switch to be symmetric?
As I understand, currently there is no way to guarantee, that hash, generated for two packet which differs only by direction (packet from connection with same MAC or IP or IP:PORT) would get in the same port on the switch and on the linux box.
Imagine that we have linux box with 2 CPUs and bond from two interfaces - eth0 (cpu node 0) and eth1 (cpu node 1). And there is an application thread which handle connection with client. Now it is possible, that incoming packet for this connection would end up in eth0 (cpu node 0) and outgoing packets would end up in eth1 (cpu node 1) which will lead to inter CPU communication.
So, is there a way to guarantee symmetric choice of bonded ports?

Best regards,
Dmitry Samsonov
Odnoklassniki.ru
Mail.ru Group
Lead System Administrator
e-mail: dmitry.samsonov@odnoklassniki.ru
