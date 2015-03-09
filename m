From: David Miller <davem@redhat.com>
Subject: Re: [net-next 0/9][pull request] Intel Wired LAN Driver Updates
 2015-03-09
Date: Mon, 09 Mar 2015 16:05:10 -0400 (EDT)
Message-ID: <20150309.160510.1331119766701559402.davem@redhat.com>
References: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50157 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbbCIUFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2015 16:05:14 -0400
In-Reply-To: <1425923742-4488-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Mon,  9 Mar 2015 10:55:33 -0700

> This series contains updates to i40e and i40evf.
> 
> Greg cleans up some "hello world" strings which were left around from
> early development.
> 
> Shannon modifies the drive to make sure the sizeof() calls are taking
> the size of the actual struct that we care about.  Also updates the
> NVMUpdate read/write so that it is less noisy when logging.  This was
> because the NVMUpdate tool does not necessarily know the ReadOnly map of
> the current NVM image, and must try reading and writing words that may be
> protected.  This generates an error out of the Firmware request that the
> driver logs.  Unfortunately, this ended up spitting out hundreds of
> bogus read/write error messages.  If a user wants the noisy logging,
> the change can be overridden by enabling the NVM update debugging.
> 
> Mitch fixes a possible deadlock issue where if a reset occurred when the
> netdev is closed, the reset task will hang in napi_disable.  Added
> ethtool RSS support as suggested by Ben Hutchings.
> 
> Jesse fixes a bug introduced in the force writeback code, where the
> interrupt rate was set to 0 (maximum) by accident.  The driver must
> correctly set the NOITR fields to avoid IT update as a side effect
> of triggering the software interrupt.
> 
> I provided a simple cleanup to make the use of PF/VF consistent, which
> was reported by Joe Perches.

Pulled, thanks Jeff.
