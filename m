From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] docbook: fix printk of ip address
Date: Thu, 30 Jul 2009 12:31:51 -0700 (PDT)
Message-ID: <20090730.123151.191002348.davem@davemloft.net>
References: <20090730122518.995a83ba.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tklauser@distanz.ch
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58420
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751284AbZG3Tbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 15:31:43 -0400
In-Reply-To: <20090730122518.995a83ba.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 30 Jul 2009 12:25:18 -0700

> Does this need to be changed to __be32?

Yes, the value passed in must be in network byte order
when using %pI4.
