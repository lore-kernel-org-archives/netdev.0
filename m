From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Configuring the same IP on multiple addresses
Date: Mon, 29 Oct 2007 14:03:37 -0400
Message-ID: <47262079.90507@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:50345 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755164AbXJ2SFK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2007 14:05:10 -0400
Received: from smtp2.fc.hp.com (smtp.cnd.hp.com [15.11.136.114])
	by atlrel6.hp.com (Postfix) with ESMTP id 866BE3663A
	for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 14:04:01 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All

Does anyone have a reason why Linux allows one to configure
the same IP or IPv6 address on multiple interfaces?

For IPv4, since linux implements a weak host model, assigning
duplicate addresses doesn't make any sense, since the addresses
really belong to the host and not the interface.

For IPv6, I can see allowing duplicate link-locals since that's
perfectly valid from the protocol perspective.  However, duplicate
globals are shouldn't be allows from the perspective of the address
architecture.

So, I am looking for technical reasons why this is permitted.

Thanks
-vlad
