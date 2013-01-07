From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next v2] ethtool: consolidate work with ethtool_ops
Date: Mon, 7 Jan 2013 19:42:11 +0000
Message-ID: <1357587731.2658.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1357585328-3405-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<richardcochran@gmail.com>, <greearb@candelatech.com>,
	<jeffrey.t.kirsher@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20363 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753829Ab3AGTmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 14:42:15 -0500
In-Reply-To: <1357585328-3405-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 20:02 +0100, Jiri Pirko wrote:
> No need to check if ethtool_ops == NULL since it can't be.
> Use local variable "ops" in functions where it is present
> instead of dev->ethtool_ops
> Introduce local variable "ops" in functions where dev->ethtool_ops is used
> many times.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
[...]

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
