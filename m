From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Resurrect napi_poll patch.
Date: Sat, 21 Jul 2007 00:42:34 -0700 (PDT)
Message-ID: <20070721.004234.122616332.davem@davemloft.net>
References: <20070720.223129.59470764.davem@davemloft.net>
	<1185002071.6344.21.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754171AbXGUHmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Jul 2007 03:42:35 -0400
In-Reply-To: <1185002071.6344.21.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 21 Jul 2007 17:14:31 +1000

> 	This looks good!  It might be nice though to go further and remove the
> internal napi_struct.  It's kind of a wart for multi-queue drivers which
> are going to have their own array (or whatever).

I guess you're suggesting to pass in a "void *" cookie instead of the
napi_struct?  You'd need to pass in a slot number or similar as well
with that kind of idea, and then it starts to push the limits or
worthwhileness.
