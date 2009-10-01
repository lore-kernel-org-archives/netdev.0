From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [PATCH] ethtool: Add a new ethtool option to flash a firmware
	image from the specified file to a device.
Date: Thu, 1 Oct 2009 11:43:59 +0530
Message-ID: <20091001061357.GA4236@serverengines.com>
References: <20090903030258.GA19401@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:30739 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752271AbZJAGNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 02:13:50 -0400
Content-Disposition: inline
In-Reply-To: <20090903030258.GA19401@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/09/09 08:33 +0530, Ajit Khaparde wrote:
> This patch adds a new "-f" option to the ethtool utility
> to flash a firmware image specified by a file, to a network device.
> The filename is passed to the network driver which will flash the image
> on the chip using the request_firmware path.
> 
> The region "on the chip" to be flashed can be specified by an option.
> It is upto the device driver to enumerate the region number passed by ethtool,
> to the region to be flashed.
> 
> The default behavior is to flash all the regions on the chip.
> 
> Usage:
> ethtool -f <interface name> <filename of firmware image>
> 
> ethtool -f <interface name> <filename of firmware image> [ REGION-NUMBER-TO-FLASH ]
> 
> Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>

When will this change make it to the ethtool source?
Anything that I need to do from my side?
I hope this is the right place to submit such changes.

Thanks
-Ajit
