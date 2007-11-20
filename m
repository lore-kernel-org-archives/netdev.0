From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 5/6] net: Make AF_UNIX per network namespace
 safe (v2)
Date: Mon, 19 Nov 2007 22:33:52 -0800 (PST)
Message-ID: <20071119.223352.17524472.davem@davemloft.net>
References: <20071115160041.GA25504@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, dlezcano@fr.ibm.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35023
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753179AbXKTGdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 01:33:53 -0500
In-Reply-To: <20071115160041.GA25504@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 15 Nov 2007 19:00:41 +0300

> Because of the global nature of garbage collection, and because of the
> cost of per namespace hash tables unix_socket_table has been kept
> global.  With a filter added on lookups so we don't see sockets from
> the wrong namespace.
> 
> Currently I don't fold the namesapce into the hash so multiple
> namespaces using the same socket name will be guaranteed a hash
> collision.
> 
> Changes from v1:
> - fixed unix_seq_open
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied, thanks.
