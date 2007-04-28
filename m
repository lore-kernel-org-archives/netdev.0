From: "Denys" <denys@visp.net.lb>
Subject: local sendto/classes/qdisc strange behaviour
Date: Sat, 28 Apr 2007 16:18:48 +0300
Message-ID: <20070428131328.M81086@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:47932 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756186AbXD1NS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 09:18:59 -0400
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id 93BF2BE3C6
	for <netdev@vger.kernel.org>; Sat, 28 Apr 2007 16:18:48 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all

I noticed, if i set up "shaper" with iproute2, u32 filters, some htb classes,
and if i have program doing sendto to nonblocking socked, sometimes i am
getting EAGAIN, even qdisc is empty. In same timed forwarded traffic is
getting buffered, and thus way i am not loosing any packet in case of small
bursts, just i have small increase in delay (that what pfifo qdisc useful for).

Is there any way to setup htb shaper, to have local sendto traffic buffered
over qdisc? (not just discareded with returned EAGAIN).

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

