From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
Date: Thu, 2 Jan 2014 18:21:11 +0000
Message-ID: <1388686871.9947.20.camel@bwh-desktop.uk.level5networks.com>
References: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8374 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbaABSVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 13:21:17 -0500
In-Reply-To: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 01:33 -0800, Jeff Kirsher wrote:
> This series contains updates to ixgbe, e1000e and igb.
> 
> Most notably is Mark Rustad's ixgbe patches to add the Live Error
> Recovery option to ixgbe as well as additional cleanups to the driver.
[...]

The Live Error Recovery option is pretty odd; it looks like a
combination of PCI hotplug and EEH.  Why is it not integrated with
either of those?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
