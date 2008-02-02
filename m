From: Adrian Bunk <bunk@kernel.org>
Subject: inet6_hash_connect() no longer uses secure_ipv6_port_ephemeral()
Date: Sat, 2 Feb 2008 23:14:54 +0200
Message-ID: <20080202211454.GB9375@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:55246 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753812AbYBBVQR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Feb 2008 16:16:17 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I do not claim to understand this code, but it doesn't seem to be 
intentional that after commit 5ee31fc1ecdcbc234c8c56dcacef87c8e09909d8 
inet6_hash_connect() now uses secure_ipv4_port_ephemeral() instead of 
secure_ipv6_port_ephemeral() (inet6_sk_port_offset() is no longer 
used and __inet_hash_connect() uses secure_ipv4_port_ephemeral()
through inet_sk_port_offset())?

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

