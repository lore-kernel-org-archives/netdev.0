From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC, 1/2] ethtool:  Implement private flags interface for
 ethtool application.
Date: Fri, 02 Sep 2011 22:27:11 +0100
Message-ID: <1314998831.3419.12.camel@bwh-desktop>
References: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Carolyn Wyborny <carolyn.wyborny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:28921 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755986Ab1IBV1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 17:27:14 -0400
In-Reply-To: <1314996631-4773-1-git-send-email-carolyn.wyborny@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-09-02 at 13:50 -0700, Carolyn Wyborny wrote:
> This patch completes the user space implementation of the private
> flags inteface in ethtool. Using -b/-B options.
[...]

Private flags are supposed to be named (string set ETH_SS_PRIV_FLAGS).
ethtool should only support getting and setting flags by name, not
number.  That way people can actually remember what the flags do and
their scripts won't break when the driver changes flag numbers.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
