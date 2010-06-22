From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: Link-local address handling for IPv4
Date: Tue, 22 Jun 2010 13:17:35 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E739702DDAE@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:46072 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756268Ab0FVNTp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 09:19:45 -0400
Received: from G6W0641.americas.hpqcorp.net (g6w0641.atlanta.hp.com [16.230.34.77])
	(using TLSv1 with cipher RC4-MD5 (128/128 bits))
	(No client certificate requested)
	by g1t0027.austin.hp.com (Postfix) with ESMTPS id 3184B38F1B
	for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 13:19:45 +0000 (UTC)
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Does the Linux kernel network stack do any specific handling of link-local address configuration and handling according to RFC 3927? I know that there is user-level code like Zeroconf / Avahi and these tools create ARP sockets directly on the specified network interfaces in order to support link-local address handling. But if I do not run any of these tools, does the kernel's ARP code take care of this, too?

Thanks,
Anna
