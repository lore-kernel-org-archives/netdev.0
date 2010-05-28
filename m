From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] netlink: bug fix: don't overrun skbs on
 vf_port dump
Date: Fri, 28 May 2010 03:42:51 -0700 (PDT)
Message-ID: <20100528.034251.242153540.davem@davemloft.net>
References: <20100528071546.4058.1332.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, netdev@vger.kernel.org, kaber@trash.net,
	arnd@arndb.de
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45732
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755853Ab0E1Kml (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 06:42:41 -0400
In-Reply-To: <20100528071546.4058.1332.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Fri, 28 May 2010 00:15:46 -0700

> From: Scott Feldman <scofeldm@cisco.com>
> 
> Noticed by Patrick McHardy: was continuing to fill skb after a
> nla_put_failure, ignoring the size calculated by upper layer.  Now,
> return -EMSGSIZE on any overruns, but also allow netdev to
> fail ndo_get_vf_port with error other than -EMSGSIZE, thus unwinding
> nest.
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied.
