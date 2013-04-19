From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/15][pull request] Intel Wired LAN Driver Updates
Date: Fri, 19 Apr 2013 14:19:45 -0400 (EDT)
Message-ID: <20130419.141945.1365252776506198187.davem@davemloft.net>
References: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45125 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135Ab3DSSTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 14:19:48 -0400
In-Reply-To: <1366327822-10741-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 18 Apr 2013 16:30:07 -0700

> This series contains updates to ixgbe and igb.
> 
> The ixgbe changes contains 2 patches from the community, one which is a
> fix from akepner to fix a issue where netif_running() in shutdown was
> not done under rtnl_lock.  The other community fix from Joe Perches
> cleans up #ifdef CONFIG_DEBUG_FS which is no longer necessary.  The
> last ixgbe patch, from Jacob Keller, adds support for WoL on 82559
> SFP+ LOM.
> 
> The remaining patches are against igb, 10 of which were previously
> submitted in a pull request where changes were requested.
> 
> The following igb patches:
>  igb: Support for 100base-fx SFP
>  igb: Support to read and export SFF-8472/8079 data
> are v2 based on feedback from Dan Carpenter and Ben Hutchings in
> the previous pull request.
> 
> The largest set of changes are in my patch to cleanup code comments
> and whitespace to align the igb driver with the networking style of
> code comments.  While cleaning up the code comments, fixed several
> other whitespace/checkpatch.pl code formatting issues.
> 
> Other notable igb patches are EEE capable devices query the PHY to
> determine what the link partner is advertising, added support for
> i354 devices and added support for spoofchk config.
> 
> The following are changes since commit c1cb0d3b569b1d21ada8666efb42dfd437617a09:
>   Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Pulled, thanks a lot Jeff.
