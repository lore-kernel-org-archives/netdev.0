From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] benet: use do_div() for 64 bit divide
Date: Fri, 27 Mar 2009 00:26:39 -0700 (PDT)
Message-ID: <20090327.002639.94312978.davem@davemloft.net>
References: <49CBA351.2000007@oracle.com>
	<20090326123005.34acd9fe@s6510>
	<49CBE123.5030204@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, sathyap@serverengines.com,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	netdev@vger.kernel.org, linux-drivers@serverengines.com
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750964AbZC0H0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2009 03:26:51 -0400
In-Reply-To: <49CBE123.5030204@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 26 Mar 2009 13:10:11 -0700

> Stephen Hemminger wrote:
> > The benet driver is doing a 64 bit divide, which is not supported in Linux kernel
> > on 32 bit architectures. The correct way to do this is to use do_div().
> > Compile tested on i386 only.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Randy Dunlap <randy.dunlap@oracle.com> # and Tested-by: (built)

Applied, thanks everyone.
