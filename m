From: Matthias Urlichs <matthias@urlichs.de>
Subject: Re: 6to4 NAT ?
Date: Mon, 7 Feb 2011 14:55:14 +0100
Message-ID: <20110207135512.GA3731@deee.intern.smurf.noris.de>
References: <4D4FC906.3030901@fox-it.com>
 <20110207124138.GW3731@deee.intern.smurf.noris.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netz.smurf.noris.de ([213.95.21.43]:37469 "EHLO
	netz.smurf.noris.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753172Ab1BGOMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 09:12:13 -0500
Content-Disposition: inline
In-Reply-To: <20110207124138.GW3731@deee.intern.smurf.noris.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

> Sounds to me like you're looking for nat64. No built in support is
> available afaik, but http://ecdysis.viagenie.ca/ provides a netfilter
> module.

Alternately, there seems to be a stateless program which does the same
thing via a TUN interface:

http://www.litech.org/tayga/

This solutions seems superior to the ecdysis kernel module because
* stateless
* no out-of-tree kernel code with concurrency issues
* while it's userland code, I don't expect to have much traffic
* it can support multiple IPv4 networks on one system
  (we have customers with overlapping RFC1912 address ranges)
* more flexible deployment

-- 
-- Matthias Urlichs
