From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool] ethtool: --set-eee sends ETHTOOL_SEEE ioctl even if
 nothing changed
Date: Sat, 6 Oct 2012 00:14:27 +0100
Message-ID: <1349478867.2819.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <1348024819-29876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17615 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752554Ab2JEXOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2012 19:14:31 -0400
In-Reply-To: <1348024819-29876-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-18 at 20:20 -0700, Jeff Kirsher wrote:
> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> When setting EEE parameters with the --set-eee command line option,
> ethtool will send the ETHTOOL_SEEE ioctl down to the driver even if
> none of the provided parameters are a change from current settings.
> Simply ignore it when that happens as done with other ethtool commands.
[...]

Applied, thanks.  Sorry for the slow response.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
