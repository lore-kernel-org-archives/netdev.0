From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH 2/2] xen: netfront: support the ethtool drvinfo hook.
Date: Fri, 20 Aug 2010 08:07:21 +0100
Message-ID: <1282288041.29609.120.camel@localhost.localdomain>
References: <1282210055.3170.2283.camel@zakaz.uk.xensource.com>
	 <1282210070-7745-2-git-send-email-ian.campbell@citrix.com>
	 <1282265462.3454.153.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"Jeremy Fitzhardinge" <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:3025 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953Ab0HTHHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Aug 2010 03:07:24 -0400
In-Reply-To: <1282265462.3454.153.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-08-20 at 01:51 +0100, Ben Hutchings wrote:
> On Thu, 2010-08-19 at 10:27 +0100, Ian Campbell wrote:
> > Causes "ethtool -i" to report something useful:
> > 	# ethtool -i eth0
> > 	driver: xen-netfront
> > 	version:
> > 	firmware-version:
> > 	bus-info: vif-0
> [...]
> 
> This should already be covered by:
> 
> commit 01414802054c382072b6cb9a1bdc6e243c74b2d5

Excellent, thanks!

> Author: Ben Hutchings <bhutchings@solarflare.com>
> Date:   Tue Aug 17 02:31:15 2010 -0700
> 
>     ethtool: Provide a default implementation of ethtool_ops::get_drvinfo
> 
> Ben.
> 


