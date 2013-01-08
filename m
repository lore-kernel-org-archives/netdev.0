From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] ethtool: consolidate work with ethtool_ops
Date: Mon, 07 Jan 2013 19:54:35 -0800 (PST)
Message-ID: <20130107.195435.763201132949773285.davem@davemloft.net>
References: <1357585328-3405-1-git-send-email-jiri@resnulli.us>
	<20130107200656.GA2090@obelix.rh>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org,
	bhutchings@solarflare.com, richardcochran@gmail.com,
	greearb@candelatech.com, jeffrey.t.kirsher@intel.com
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523Ab3AHDyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:54:36 -0500
In-Reply-To: <20130107200656.GA2090@obelix.rh>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Mon, 7 Jan 2013 18:06:56 -0200

> On Mon, Jan 07, 2013 at 08:02:08PM +0100, Jiri Pirko wrote:
>> No need to check if ethtool_ops == NULL since it can't be.
>> Use local variable "ops" in functions where it is present
>> instead of dev->ethtool_ops
>> Introduce local variable "ops" in functions where dev->ethtool_ops is used
>> many times.
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
> 
> Reviewed-by: Flavio Leitner <fbl@redhat.com>

Applied.
