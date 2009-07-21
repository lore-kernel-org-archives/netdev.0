From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 1/2] mcastv6: Local variable shadows function argument
Date: Tue, 21 Jul 2009 11:13:38 -0700 (PDT)
Message-ID: <20090721.111338.84499428.davem@davemloft.net>
References: <20090721181153.GA5970@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52424
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754461AbZGUSNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 14:13:32 -0400
In-Reply-To: <20090721181153.GA5970@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Jul 2009 20:11:53 +0200

> mcastv6: Local variable shadows function argument
> 
> The local variable 'idev' shadows the function argument 'idev' to
> ip6_mc_add_src(). Fixed by removing the local declaration, as pmc->idev
> should be identical with 'idev' passed as argument.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: David L Stevens <dlstevens@us.ibm.com>

Applied to net-next-2.6
