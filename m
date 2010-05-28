From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] netlink: bug fix: wrong size was
 calculated for vfinfo list blob
Date: Fri, 28 May 2010 03:42:56 -0700 (PDT)
Message-ID: <20100528.034256.116357450.davem@davemloft.net>
References: <20100528071546.4058.1332.stgit@localhost.localdomain>
	<20100528071551.4058.24521.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chrisw@redhat.com, netdev@vger.kernel.org, kaber@trash.net,
	arnd@arndb.de
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45740
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932141Ab0E1Kmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 May 2010 06:42:46 -0400
In-Reply-To: <20100528071551.4058.24521.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Fri, 28 May 2010 00:15:51 -0700

> From: Scott Feldman <scofeldm@cisco.com>
> 
> The wrong size was being calculated for vfinfo.  In one case, it was over-
> calculating using nlmsg_total_size on attrs, in another case, it was
> under-calculating by assuming ifla_vf_* structs are packed together, but
> each struct is it's own attr w/ hdr (and padding).
> 
> Signed-off-by: Scott Feldman <scofeldm@cisco.com>

Applied.
