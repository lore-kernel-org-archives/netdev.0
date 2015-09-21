From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
 2015-09-17
Date: Sun, 20 Sep 2015 22:27:11 -0700 (PDT)
Message-ID: <20150920.222711.856164019299998327.davem@davemloft.net>
References: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, john.ronciak@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48760 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752389AbbIUF1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 01:27:12 -0400
In-Reply-To: <1442535480-65222-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 17 Sep 2015 17:17:52 -0700

> This series contains updates to i40e and i40evf.
> 
> Shannon provides updates to i40e and i40evf to resolve an issue with the
> nvmupdate utility.  First renames a variable name to reduce confusion and
> to differentiate it from the actual user variable.  Then added the ability
> to save the admin queue write back descriptor if a caller supplies a
> buffer for it to be saved into.  Added a new GetStatus command so that
> the NVM update tool can query the current status instead of doing fake
> write requests to probe for readiness.  Added wait states to the NVM
> update state machine to signify when waiting for an update operation to
> finish, whether we are in the middle of a set of write operations, or we
> are now idle but waiting.  Then added a facility to run admin queue
> commands through the NVM update utility in order to allow the update
> tools to interact with the firmware and do special commands needed for
> updates and configuration changes.  Also added a facility to recover the
> result of a previously run admin queue command.

Pulled, thanks Jeff.
