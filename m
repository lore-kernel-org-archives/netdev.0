From: Matt Domsch <Matt_Domsch@Dell.com>
Subject: Re: [PATCH] Add firmware label support to iproute2
Date: Thu, 19 Aug 2010 16:33:14 -0500
Message-ID: <20100819213314.GA26135@auslistsprd01.us.dell.com>
References: <20100812173537.GA29784@auslistsprd01.us.dell.com> <20100812141240.417949e2@s6510> <EDA0A4495861324DA2618B4C45DCB3EE612E34@blrx3m08.blr.amer.dell.com> <20100818144124.33a72453@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Narendra_K@Dell.com, netdev@vger.kernel.org, Charles_Rose@Dell.com,
	Jordan_Hargrave@Dell.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:7217 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101Ab0HSVdQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 17:33:16 -0400
Content-Disposition: inline
In-Reply-To: <20100818144124.33a72453@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 18, 2010 at 02:41:24PM -0700, Stephen Hemminger wrote:
> The netdev_alias_to_kernelname should only happen after normal lookup failed.

Stephen, can you enlighten me as to the "right" way to do interface
name lookups?  While I can still find examples of parsing
/proc/net/dev, or globbing /sys/class/net/*, I expect these aren't the
preferred method anymore.  Your own iproute2 suite uses RTM_GETLINK
netlink calls, though for the seeming simple case of "give me a list of all
interfaces", your path through there is far more capable (and
complex) than I would hope to need.

Please advise.

> Also how does ifindex to name mapping work?

libnetdevname does not use ifindex at all at present.

Thanks,
Matt

-- 
Matt Domsch
Technology Strategist
Dell | Office of the CTO
