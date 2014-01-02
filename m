From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 6/9] ixgbe: Add Live Error Recovery configuration
 option
Date: Thu, 2 Jan 2014 18:15:13 +0000
Message-ID: <1388686513.9947.14.camel@bwh-desktop.uk.level5networks.com>
References: <1388655221-25428-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1388655221-25428-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Mark Rustad <mark.d.rustad@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8297 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752051AbaABSPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 13:15:17 -0500
In-Reply-To: <1388655221-25428-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 01:33 -0800, Jeff Kirsher wrote:
> From: Mark Rustad <mark.d.rustad@intel.com>
> 
> CONFIG_IXGBE_LER is added to control LER, Live Error Recovery
> support to save a little CPU utilization in environments that
> don't support LER. Thunderbolt environments also benefit from
> having this enabled.
[...]

This is a strange way of explaining it:

'Disabling it does A.  Enabling it also does B.'

There's no 'also' here; users have to trade-off A against B.
The Kconfig help text has the same problem.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
