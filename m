From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 12/12] ixgbe: update ntuple filter configuration
Date: Fri, 07 Jan 2011 01:02:38 +0000
Message-ID: <1294362158.11825.78.camel@bwh-desktop>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1294360199-9860-13-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28193 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754849Ab1AGBCl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 20:02:41 -0500
In-Reply-To: <1294360199-9860-13-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-01-06 at 16:29 -0800, jeffrey.t.kirsher@intel.com wrote:
> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> This change fixes several issues found in ntuple filtering while I was
> doing the ATR refactor.
> 
> Specifically I updated the masks to work correctly with the latest version
> of ethtool,
[...]

Did the previous code not correctly handle a zero value with a non-zero
mask for some fields?  If so, I can revert that change to ethtool.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

