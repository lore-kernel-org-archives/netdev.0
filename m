From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [BRIDGE] Set features based on slave's ones
Date: Thu, 19 May 2005 11:58:32 -0700 (PDT)
Message-ID: <20050519.115832.111205328.davem@davemloft.net>
References: <200505191106.53136.jdmason@us.ibm.com>
	<Pine.LNX.4.62.0505192019090.8076@webhosting.rdsbv.ro>
	<200505191247.55138.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: util@deuroconsult.ro, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jdmason@us.ibm.com
In-Reply-To: <200505191247.55138.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Jon Mason <jdmason@us.ibm.com>
Date: Thu, 19 May 2005 12:47:55 -0500

> My point is that some features the user might want enabled regardless of 
> whether all devices support them.  An example of this is where a system has 
> hardware checksum support for all devices except one.  In this case, it would 
> be benefitial to have this device do the checksum in software (via 
> skb_checksum_help() call in dev_queue_xmit()).

If "SG and checksumming is so common these days" as others have
stated, what you are describing is a totally uncommon scenerio.  What
Catalin is proposing is infinitely better than what we have today.
