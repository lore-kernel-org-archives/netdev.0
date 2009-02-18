From: =?utf-8?b?0KXQsNC90LrQuNC9INCa0L7QvdGB0YLQsNC90YLQuNC9?=
	<homecreate@list.ru>
Subject: Why linux keeps connected routes when link goes down
Date: Thu, 19 Feb 2009 02:03:40 +0500
Message-ID: <200902190203.41497.homecreate@list.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.mail.ru ([94.100.176.18]:5684 "EHLO mx4.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753246AbZBRXtM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Feb 2009 18:49:12 -0500
Received: from mx39.mail.ru (mx39.mail.ru [94.100.176.53])
	by mx4.mail.ru (mPOP.Fallback_MX) with ESMTP id 3563D51BC20
	for <netdev@vger.kernel.org>; Thu, 19 Feb 2009 00:04:17 +0300 (MSK)
Received: from [78.29.50.71] (port=6577 helo=mini.localnet)
	by mx39.mail.ru with asmtp
	id 1LZta5-000Ivw-00
	for netdev@vger.kernel.org; Thu, 19 Feb 2009 00:03:45 +0300
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!
Why kernel keeps connected routes when link is not in RUNNING state? It's not 
only linux behavior, some other OSes do so, but why?
It's interesting for me because I have a problem with setting up Quagga for 
OSPF support. When link goes down (!IFF_RUNNING), Quagga updates only its own 
routing table. I must use ifplugd to update routes in kernel (actually to 
delete connected route), but I think it is not a right way.
So the main question is: why linux keeps connected routes when link goes down?
PS: ``ip monitor'' reports about link fail after a minute or longer (on 
8139too and 3c905x). On some Acorp cards it doesn't notice link failure. Is it 
a bad driver or crappy cards? On r8169 I have no problems

--
Konstantin
E-mail homecreate@list.ru
Jabber homecreate@jabber.ru
