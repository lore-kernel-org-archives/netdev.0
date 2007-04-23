From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] SIOCGIFCOUNT implementation
Date: Mon, 23 Apr 2007 14:26:30 -0700 (PDT)
Message-ID: <20070423.142630.21932914.davem@davemloft.net>
References: <200704211148.52705.ak@suse.de>
	<20070421.104047.41636018.davem@davemloft.net>
	<20070423141226.1c2127ce@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ak@suse.de, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48968
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754262AbXDWV0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2007 17:26:23 -0400
In-Reply-To: <20070423141226.1c2127ce@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 23 Apr 2007 14:12:26 -0700

> Trivial implementation of SIOCGIFCOUNT.
> If you search the archives, this was suggested and rejected
> 6 years ago. But there maybe legacy Unix applications that
> could actually use it.
> 
> Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

It makes no sense given that you can get this information
with SIOCGIFCONF by supplying a NULL ifc.ifc_buf buffer.
The equivalent of SIOCGIFCOUNT can be obtained by dividing ifc.ifc_len
by the size of one interface entry.

Please also tell me what legacy application could actually
use this thing when BSD itself doesn't even implement it?

A google code search for SIOCGIFCOUNT is fun too.

In fact SIOCGIFCOUNT aparently got removed in 2.2.x, so
let's keep it that way.

There is no reason to add support for this, truly.

