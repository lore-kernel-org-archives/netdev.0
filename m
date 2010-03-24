From: David Miller <davem@davemloft.net>
Subject: Re: [patch] wimax: remove unneeded variable
Date: Wed, 24 Mar 2010 13:36:56 -0700 (PDT)
Message-ID: <20100324.133656.200772463.davem@davemloft.net>
References: <20100324115603.GD21571@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andre.goddard@gmail.com,
	adobriyan@gmail.com, jkosina@suse.cz,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42964
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932739Ab0CXUgd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Mar 2010 16:36:33 -0400
In-Reply-To: <20100324115603.GD21571@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 24 Mar 2010 14:56:03 +0300

> We never actually use "dev" so I removed it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

I think the intention was to pass it into to these
stupid function call tracing debugging macros the
WIMAX stuff has.  It's passing NULL currently.

Anyways, I've applied this, thanks.

But seriously, why is every developer of some new subsystem or driver
inclined to add such ugly debugging infrastructure?  It's seemingly
the first thing they do before writing any code.

I'd very much like to see a patch that removes all of this junk and
"rm -f include/linux/wimax/debug.h"
