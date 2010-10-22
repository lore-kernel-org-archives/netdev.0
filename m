From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC][net-next-2.6 PATCH 3/4] ethtool: set hard_header_len
 using ETH_FLAG_{TX|RX}VLAN
Date: Fri, 22 Oct 2010 14:00:16 +0100
Message-ID: <1287752416.2316.2.camel@achroite.uk.solarflarecom.com>
References: <20101021221004.22906.58438.stgit@jf-dev1-dcblab>
	 <20101021221015.22906.3516.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:46733 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751352Ab0JVNAT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 09:00:19 -0400
In-Reply-To: <20101021221015.22906.3516.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-10-21 at 15:10 -0700, John Fastabend wrote:
> Toggling the vlan tx|rx hw offloads needs to set the hard_header_len
> as well otherwise we end up using LL_RESERVED_SPACE incorrectly.
> This results in pskb_expand_head() being used unnecessarily.
> 
> This add a check in ethtool_op_set_flags to catch the ETH_FLAG_TXVLAN
> flag and set the header length.
[...]

Note that not every driver that implements the set_flags operation calls
back to ethtool_op_set_flags().

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

