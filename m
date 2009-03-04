From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] IPv6: add "disable" module parameter support to
 ipv6.ko
Date: Wed, 04 Mar 2009 03:21:45 -0800 (PST)
Message-ID: <20090304.032145.115092643.davem@davemloft.net>
References: <49ADE95F.8060607@hp.com>
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
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40073
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751719AbZCDLWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 06:22:01 -0500
In-Reply-To: <49ADE95F.8060607@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Tue, 03 Mar 2009 21:37:19 -0500

> 
> Add "disable" module parameter support to ipv6.ko by specifying
> "disable=1" on module load.  We just do the minimum of initializing
> inetsw6[] so calls from other modules to inet6_register_protosw()
> won't OOPs, then bail out.  No IPv6 addresses or sockets can be
> created as a result, and a reboot is required to enable IPv6.
> 
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Applied, but you have to do something about your email client
and what it does to patches Brian.

Every line that starts with a single space then TABs was
replaced with two space characters then the TABs.  Long
lines were also chopped up.
