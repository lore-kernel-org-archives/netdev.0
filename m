From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Does rtnl_lock inhibit incoming traffic?
Date: Wed, 29 May 2013 21:08:29 +0200
Message-ID: <51A6522D.2000008@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:12288 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759396Ab3E2TIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 15:08:32 -0400
Received: from [192.168.178.49] (p5B0B18A9.dip0.t-ipconnect.de [91.11.24.169])
	by smtp.strato.de (joses mo41) (RZmta 31.27 DYNA|AUTH)
	with ESMTPA id i06388p4THRBLF for <netdev@vger.kernel.org>;
	Wed, 29 May 2013 21:08:29 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

AFAIK the rtnl_lock is used (at least) to protect the configuration of
netdevices and routing tables.

Is the reception of incoming traffic inhibited while the rtnl_lock is set, or
would i need to protect the data structures to be modified with an additional
spinlock_bh() / write_lock_bh()?

Like this one here:

http://lxr.linux.no/#linux+v3.9.4/net/ipv6/ip6mr.c#L1573

Regards,
Oliver
