From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [patch net-next v2] ethtool: consolidate work with ethtool_ops
Date: Mon, 7 Jan 2013 18:06:56 -0200
Message-ID: <20130107200656.GA2090@obelix.rh>
References: <1357585328-3405-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com, richardcochran@gmail.com,
	greearb@candelatech.com, jeffrey.t.kirsher@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15438 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796Ab3AGUHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jan 2013 15:07:09 -0500
Content-Disposition: inline
In-Reply-To: <1357585328-3405-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 07, 2013 at 08:02:08PM +0100, Jiri Pirko wrote:
> No need to check if ethtool_ops == NULL since it can't be.
> Use local variable "ops" in functions where it is present
> instead of dev->ethtool_ops
> Introduce local variable "ops" in functions where dev->ethtool_ops is used
> many times.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---

Reviewed-by: Flavio Leitner <fbl@redhat.com>
