From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 00/17][pull request] Intel Wired LAN Driver
 Updates 2015-06-17
Date: Thu, 18 Jun 2015 03:59:27 -0700 (PDT)
Message-ID: <20150618.035927.1651374052675221653.davem@davemloft.net>
References: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41430 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753428AbbFRKrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2015 06:47:48 -0400
In-Reply-To: <1434545704-112470-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 17 Jun 2015 05:54:47 -0700

> This series contains updates to fm10k only.
> 
> Alex provides two fixes for the fm10k, first folds the fm10k_pull_tail()
> call into fm10k_add_rx_frag(), this way the fragment does not have to be
> modified after it is added to the skb.  The second fixes missing braces
> to an if statement.
> 
> The remaining patches are from Jacob which contain improvements and fixes
> for fm10k.  First fix makes it so that invalid address will simply be
> skipped and allows synchronizing the full list to proceed with using
> iproute2 tool.  Fixed a possible kernel panic by using the correct
> transmit timestamp function.  Simplified the code flow for setting the
> IN_PROGRESS bit of the shinfo for an skb that we will be timestamping.
> Fix a bug in the timestamping transmit enqueue code responsible for a
> NULL pointer dereference and invalid access of the skb list by freeing
> the clone in the cases where we did not add it to the queue.  Update the
> PF code so that it resets the empty TQMAP/RQMAP regirsters post-VFLR to
> prevent innocent VF drivers from triggering malicious driver events.
> The SYSTIME_CFG.Adjust direction bit is actually supposed to indicate
> that the adjustment is positive, so fix the code to align correctly with
> the hardware and documentation.  Cleanup local variable that is no longer
> used after a previous refactor of the code.  Fix the code flow so that we
> actually clear the enabled flag as part of our removal of the LPORT.
> 
> v2:
>  - updated patch 07 description based on feedback from Sergei Shtylyov
>  - updated patch 09 & 10 to use %d in error message based on feedback
>    from Sergei Shtylyov

Pulled, thanks Jeff.
