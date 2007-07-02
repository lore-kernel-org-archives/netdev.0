From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 2.6.21.1] nfs-root: added possibility to override default MTU (for UDP jumbo frames)
Date: Mon, 02 Jul 2007 16:09:14 +0200
Message-ID: <m3fy46rj79.fsf@maximus.localdomain>
References: <E1I5LAW-0004Dn-8b@skyboo.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: manio@skyboo.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:48542 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753037AbXGBOJQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jul 2007 10:09:16 -0400
In-Reply-To: <E1I5LAW-0004Dn-8b@skyboo.net> (manio@skyboo.net's message of "Mon, 02 Jul 2007 14:38:16 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

manio@skyboo.net writes:

> To use a NFS-root for UDP jumbo frames the kernel on the client need to bring
> up interface with MTU set to 9000 bytes - otherwise it cannot contact server
> with jumbo frames enabled (nfs server not responding, still trying) and
> cannot
> boot. Added a kernel parameter named 'ipmtu' which can be used to specify
> initial MTU size when booting via nfsroot.

Isn't the whole IP autoconfig and NFS root set to die?
Why not do it in initramfs?
-- 
Krzysztof Halasa
