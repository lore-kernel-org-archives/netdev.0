From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: use the appropriate namespace pid
Date: Mon, 22 Mar 2010 20:25:26 -0700 (PDT)
Message-ID: <20100322.202526.141239221.davem@davemloft.net>
References: <20100320013850.GA13239@boeing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.goff@boeing.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37689
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754084Ab0CWDZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 23:25:03 -0400
In-Reply-To: <20100320013850.GA13239@boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Goff <thomas.goff@boeing.com>
Date: Fri, 19 Mar 2010 18:38:50 -0700

> This was included in OpenVZ kernels but wasn't integrated upstream.
>>From git://git.openvz.org/pub/linux-2.6.24-openvz:
> 
> 	commit 5c69402f18adf7276352e051ece2cf31feefab02
> 	Author: Alexey Dobriyan <adobriyan@openvz.org>
> 	Date:   Mon Dec 24 14:37:45 2007 +0300
> 
> 	    netlink: fixup ->tgid to work in multiple PID namespaces
> 
> Signed-off-by: Tom Goff <thomas.goff@boeing.com>

BTW, we're ok without this.

The 'pid' in this code is just an arbitrary port number.  We are
merely using the tgid to seed the port allocator, so it doesn't have
to be the real proper tgid.

I'm therefore dropping this for now.  If Alexey can show why we
might need this, we can revisit the patch.
