From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][PATCH] ethtool: Add reset operation
Date: Fri, 02 Oct 2009 12:00:19 +0100
Message-ID: <1254481219.23350.77.camel@localhost>
References: <1254426195.2735.16.camel@achroite>
	 <20091002104010.GA19862@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ajit Khaparde <ajitk@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25761 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757648AbZJBLAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 07:00:19 -0400
In-Reply-To: <20091002104010.GA19862@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-02 at 16:10 +0530, Ajit Khaparde wrote:
[...]
> Can you tell the intention behind this copy_to_user?
> Do you envision drivers sending back some data to the userland - may be
> sometime in future?

This allows userland to see which components were actually reset.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

