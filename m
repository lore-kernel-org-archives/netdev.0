From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/14][pull request] Intel Wired LAN Driver Updates
 2015-05-28
Date: Sat, 30 May 2015 18:10:49 -0700 (PDT)
Message-ID: <20150530.181049.2210101257408283425.davem@davemloft.net>
References: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38160 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754038AbbEaBKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 May 2015 21:10:50 -0400
In-Reply-To: <1432812339-17129-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 28 May 2015 04:25:25 -0700

> This series contains updates to ethtool, ixgbe, i40e and i40evf.
> 
> John adds helper routines for ethtool to pass VF to rx_flow_spec.  Since
> the ring_cookie is 64 bits wide which is much larger than what could be
> used for actual queue index values, provide helper routines to pack a VF
> index into the cookie.  Then John provides a ixgbe patch to allow flow
> director to use the entire queue space.
> 
> Neerav provides a i40e patch to collect XOFF Rx stats, where it was not
> being collected before.
> 
> Anjali provides ATR support for tunneled packets, as well as stats to
> count tunnel ATR hits.  Cleaned up PF struct members which are
> unnecessary, since we can use the stat index macro directly.  Cleaned
> up flow director ATR/SB messages to a higher debug level since they
> are not useful unless silicon validation is happening.
> 
> Greg provides a patch to disable offline diagnostics if VFs are enabled
> since ethtool offline diagnostic tests are not designed (out of scope)
> to disable VF functions for testing and re-enable afterward.  Also cleans
> up TODO comment that is no longer needed.
> 
> Vasu provides a fix an FCoE EOF case where i40e_fcoe_ctxt_eof() maybe
> called before i40e_fcoe_eof_is_supported() is called.
> 
> Jesse adds skb->xmit_more support for i40evf.  Then provides a performance
> enhancement for i40evf by inlining some functions which provides a 15%
> gain in small packet performance.  Also cleans up the use of time_stamp
> since it is no longer used to determine if there is a tx_hang and was
> a part of a previous tx_hang design which is no longer used.

Pulled, thanks Jeff.
