From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Sat, 29 Apr 2006 10:10:22 +1000
Message-ID: <1146269423.8029.65.camel@localhost.localdomain>
References: <1146212660.8029.38.camel@localhost.localdomain>
	 <20060428.122102.76435590.davem@davemloft.net>
	 <1146261844.8029.54.camel@localhost.localdomain>
	 <20060428.153833.68265167.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: caitlinb@broadcom.com, johnpol@2ka.mipt.ru, kelly@au1.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:19121 "EHLO ozlabs.org")
	by vger.kernel.org with ESMTP id S932464AbWD2AKv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 20:10:51 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060428.153833.68265167.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-04-28 at 15:38 -0700, David S. Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Sat, 29 Apr 2006 08:04:04 +1000
> 
> > You're still thinking you can bypass classifiers for established
> > sockets, but I really don't think you can.  I think the simplest
> > solution is to effectively remove from (or flag) the established &
> > listening hashes anything which could be effected by classifiers, so
> > those packets get send through the default channel.
> 
> OK, when rules are installed, the socket channel mappings are
> flushed.  This is your idea right?

Yeah.  First off, all flushed.  Later on, we get selective.

Rusty.
-- 
 ccontrol: http://ozlabs.org/~rusty/ccontrol

