From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 28 Apr 2006 15:38:33 -0700 (PDT)
Message-ID: <20060428.153833.68265167.davem@davemloft.net>
References: <1146212660.8029.38.camel@localhost.localdomain>
	<20060428.122102.76435590.davem@davemloft.net>
	<1146261844.8029.54.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, johnpol@2ka.mipt.ru, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:50057
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750764AbWD1Wia (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Apr 2006 18:38:30 -0400
To: rusty@rustcorp.com.au
In-Reply-To: <1146261844.8029.54.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 29 Apr 2006 08:04:04 +1000

> You're still thinking you can bypass classifiers for established
> sockets, but I really don't think you can.  I think the simplest
> solution is to effectively remove from (or flag) the established &
> listening hashes anything which could be effected by classifiers, so
> those packets get send through the default channel.

OK, when rules are installed, the socket channel mappings are
flushed.  This is your idea right?
