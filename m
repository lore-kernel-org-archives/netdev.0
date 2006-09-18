From: David Miller <davem@davemloft.net>
Subject: Re: [GENL]: Provide more information to userspace about registered
 genl families
Date: Mon, 18 Sep 2006 00:02:16 -0700 (PDT)
Message-ID: <20060918.000216.108741287.davem@davemloft.net>
References: <20060831212129.GF3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:41350
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965508AbWIRHCR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:02:17 -0400
To: tgraf@suug.ch
In-Reply-To: <20060831212129.GF3470@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 31 Aug 2006 23:21:29 +0200

> Additionaly exports the following information when providing
> the list of registered generic netlink families:
>   - protocol version
>   - header size
>   - maximum number of attributes
>   - list of available operations including
>       - id
>       - flags
>       - avaiability of policy and doit/dumpit function
> 
> libnl HEAD provides a utility to read this new information:
> 
> 	0x0010 nlctrl version 1
> 	    hdrsize 0 maxattr 6
> 	      op GETFAMILY (0x03) [POLICY,DOIT,DUMPIT]
> 	0x0011 NLBL_MGMT version 1
> 	    hdrsize 0 maxattr 0
> 	      op unknown (0x02) [DOIT]
> 	      op unknown (0x03) [DOIT]
> 	      ....
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied to net-2.6.19, thanks Thomas.
