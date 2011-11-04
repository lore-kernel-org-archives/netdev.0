From: David Miller <davem@davemloft.net>
Subject: Re: [patch] bonding: comparing a u8 with -1 is always false
Date: Fri, 04 Nov 2011 18:37:38 -0400 (EDT)
Message-ID: <20111104.183738.2111276141585306607.davem@davemloft.net>
References: <20111104182138.GB5796@elgon.mountain>
	<10444.1320436921@death>
	<20111104205351.GQ4682@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, wpan@redhat.com, andy@greyhouse.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	bhutchings@solarflare.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34276 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973Ab1KDWhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 18:37:48 -0400
In-Reply-To: <20111104205351.GQ4682@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 4 Nov 2011 23:53:51 +0300

> On Fri, Nov 04, 2011 at 01:02:01PM -0700, Jay Vosburgh wrote:
>> 
>> 	Since you #define SPEED_UNKNOWN to -1 (below), how does this
>> actually change anything?  Did you mean 0xffff (because struct
>> ethtool_cmd's speed is a u16)?
>> 
> 
> Sorry I could have explained this better in the changelog.  The
> slave->speed is stored in a u32 and the -1 works fine as is.
> Obviously, as you point out the define doesn't change anything.  I
> just changed it so it would look symetric with DUPLEX_UNKNOWN.
> 
> But I think you missed that I defined #define DUPLEX_UNKNOWN 0xff.
> Before it we used a -1 for both and that didn't work.
> 
> I can resend this with a note about the SPEED_UNKNOWN cleanup if
> you'd like.  I'll do that tomorrow or Sunday.

That won't be necessary, I'll apply your patch as-is.

Thanks Dan.
