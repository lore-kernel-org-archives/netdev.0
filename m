From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv4 net-next-2.6] ethtool: Added support for FW dump
Date: Fri, 13 May 2011 14:40:01 -0400 (EDT)
Message-ID: <20110513.144001.1731111272250389970.davem@davemloft.net>
References: <1305240515-29237-1-git-send-email-anirban.chakraborty@qlogic.com>
	<1305240515-29237-2-git-send-email-anirban.chakraborty@qlogic.com>
	<1305241507.14174.3.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirban.chakraborty@qlogic.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219Ab1EMSkH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 14:40:07 -0400
In-Reply-To: <1305241507.14174.3.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 13 May 2011 00:05:07 +0100

> On Thu, 2011-05-12 at 15:48 -0700, Anirban Chakraborty wrote:
>> Added code to take FW dump via ethtool. Dump level can be controlled via setting the
>> dump flag. A get function is provided to query the current setting of the dump flag.
>> Dump data is obtained from the driver via a separate get function.
>> 
>> Changes from v3:
>> Fixed buffer length issue in ethtool_get_dump_data function.
>> Updated kernel doc for ethtool_dump struct and get_dump_flag function.
>> 
>> Changes from v2:
>> Provided separate commands for get flag and data.
>> Check for minimum of the two buffer length obtained via ethtool and driver and
>> use that for dump buffer
>> Pass up the driver return error codes up to the caller.
>> Added kernel doc comments.
>> 
>> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> There is one tiny error I didn't notice before, which I think David can
> fix up if and when he applies this:

Applied with "u8/__u8" fixed up, thanks!
