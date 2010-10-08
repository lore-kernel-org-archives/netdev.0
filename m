From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: strcpy() => strlcpy()
Date: Fri, 08 Oct 2010 10:23:12 -0700 (PDT)
Message-ID: <20101008.102312.71118938.davem@davemloft.net>
References: <20101005163448.GH5692@bicker>
	<20101005164306.GP19804@ZenIV.linux.org.uk>
	<20101006051735.GD5409@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, isdn@linux-pingi.de,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35702
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753893Ab0JHRWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 13:22:50 -0400
In-Reply-To: <20101006051735.GD5409@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Wed, 6 Oct 2010 07:17:35 +0200

> setup.phone and setup.eazmsn are 32 character buffers.
> rcvmsg.msg_data.byte_array is a 48 character buffer.
> sc_adapter[card]->channel[rcvmsg.phy_link_no - 1].dn is 50 chars.
> 
> The rcvmsg struct comes from the memcpy_fromio() in receivemessage().
> I guess that means it's data off the wire.  I'm not very familiar with
> this code but I don't see any reason to assume these strings are NULL
> terminated.
> 
> Also it's weird that "dn" in a 50 character buffer but we only seem to
> use 32 characters.  In drivers/isdn/sc/scioc.h, "dn" is only a 49
> character buffer.  So potentially there is still an issue there.
> 
> The important thing for now is to prevent the memory corruption.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
