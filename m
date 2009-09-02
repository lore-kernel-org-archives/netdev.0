From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: Re: [RFC][PATCH][v5] net/ethtool: Add support for the ethtool
	feature to flash firmware image from a specified file.
Date: Wed, 2 Sep 2009 21:52:43 +0530
Message-ID: <20090902162241.GB23228@serverengines.com>
References: <20090821165416.GA17102@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:43509 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750848AbZIBQaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 12:30:52 -0400
Received: by fxm17 with SMTP id 17so912502fxm.37
        for <netdev@vger.kernel.org>; Wed, 02 Sep 2009 09:30:54 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090821165416.GA17102@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/08/09 22:24 +0530, Ajit Khaparde wrote:
> This patch adds support to flash a firmware image to a device using ethtool.
> The driver gets the filename of the firmware image and flashes the image
> using the request firmware path.
> 
> The region "on the chip" to be flashed can be specified by an option.
> It is upto the device driver to enumerate the region number passed by ethtool,
> to the region to be flashed.
> 
> The default behavior is to flash all the regions on the chip.
David, 
Is this patch good enough for being accepted? Please let me know if any more 
work has to be done on this. 

I want to send the changes to the be2net driver which would use this 
new ethtool feature.  Any ETA for applying the patch to the git tree? 
I will schedule my driver patch according to that. 

Thanks 
-Ajit
