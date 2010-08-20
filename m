From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] xen: netfront: support the ethtool drvinfo hook.
Date: Fri, 20 Aug 2010 01:51:02 +0100
Message-ID: <1282265462.3454.153.camel@localhost>
References: <1282210055.3170.2283.camel@zakaz.uk.xensource.com>
	 <1282210070-7745-2-git-send-email-ian.campbell@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>
To: Ian Campbell <ian.campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:35432 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476Ab0HTAvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 20:51:07 -0400
In-Reply-To: <1282210070-7745-2-git-send-email-ian.campbell@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-08-19 at 10:27 +0100, Ian Campbell wrote:
> Causes "ethtool -i" to report something useful:
> 	# ethtool -i eth0
> 	driver: xen-netfront
> 	version:
> 	firmware-version:
> 	bus-info: vif-0
[...]

This should already be covered by:

commit 01414802054c382072b6cb9a1bdc6e243c74b2d5
Author: Ben Hutchings <bhutchings@solarflare.com>
Date:   Tue Aug 17 02:31:15 2010 -0700

    ethtool: Provide a default implementation of ethtool_ops::get_drvinfo

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

