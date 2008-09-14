From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] ethtool: command line support for lro
Date: Sat, 13 Sep 2008 22:09:05 -0400
Message-ID: <48CC7241.3080008@pobox.com>
References: <1204898997.4220.41.camel@moonstone.uk.level5networks.com> <20080307082538.1a674ae1@extreme> <1204909575.4220.71.camel@moonstone.uk.level5networks.com> <20080307134312.037e2cf6@extreme> <20080310180706.GF12660@solarflare.com> <20080417121119.GI21637@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Kieran Mansley <kmansley@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51741 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751566AbYINCJK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 22:09:10 -0400
In-Reply-To: <20080417121119.GI21637@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Add lro support to command in similar manner to TSO, GSO, etc.
> The file ethtool-copy.h is updated to be sanitised version of
> ethtool.h from 2.6.25-rc4 (ie make headers_install)
> 
> Based on patch by Stephen Hemminger
> <http://article.gmane.org/gmane.linux.network/88124>.
> 
> My changes:
> - Changed error return codes for setting LRO to be unique.
> - Report failure to get device flags, consistent with other offload settings.
> - Fixed code spacing.
> 
> Tested with the sfc driver.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

applied


