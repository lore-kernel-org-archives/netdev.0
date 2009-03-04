From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] SCTP: change sctp_ctl_sock_init() to try IPv4 if
 IPv6 fails
Date: Wed, 04 Mar 2009 03:22:00 -0800 (PST)
Message-ID: <20090304.032200.138148275.davem@davemloft.net>
References: <49ADE9BE.2040303@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvidjaar@mail.ru, vladislav.yasevich@hp.com,
	chuck.lever@oracle.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org, fubar@us.ibm.com
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40083
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754376AbZCDLWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 06:22:16 -0500
In-Reply-To: <49ADE9BE.2040303@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 03 Mar 2009 21:38:54 -0500

> 
> Change sctp_ctl_sock_init() to try IPv4 if IPv6 socket registration
> fails.  Required if the IPv6 module is loaded with "disable=1",
> else SCTP will fail to load.
> 
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Also applied, and also this patch had the same corruption issues.
