From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 0/2] tlan: fix earlier fixes, remove big buffer mode
Date: Tue, 16 Dec 2008 17:24:50 +0200
Message-ID: <4947C842.1020503@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw02.mail.saunalahti.fi ([195.197.172.116]:40880 "EHLO
	gw02.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752070AbYLPPfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 10:35:05 -0500
Received: from retiisi.dyndns.org (a91-152-223-52.elisa-laajakaista.fi [91.152.223.52])
	by gw02.mail.saunalahti.fi (Postfix) with ESMTP id E762613992B
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:24:50 +0200 (EET)
Received: from [192.168.1.1] (masiina.localdomain [192.168.1.1])
	by retiisi.dyndns.org (Postfix) with ESMTP id A645252E28
	for <netdev@vger.kernel.org>; Tue, 16 Dec 2008 17:24:50 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Unfortunately it seems that my last patch introduced a few problems.

So here are two patches: the first one fixes the pci memory unmapping. 
The second one removes the big buffer mode.

That mode has never worked for me and I've been using tlan cards since 
2001 or so. With Google I could find one case where someone claimed it 
was working on 2.4.0-test1-ac7. ;-)

<URL:http://lkml.indiana.edu/hypermail/linux/kernel/0006.0/0193.html>

There's another (likely) bug in the bbuf mode (think skb copying there 
by txlen bytes), introduced by my earlier patch, which is fixed by the 
second patch by removing the mode altogether.

Cheers,

-- 
Sakari Ailus
sakari.ailus@iki.fi
