From: David Miller <davem@redhat.com>
Subject: Re: [net 0/3][pull request] Intel Wired LAN Driver Updates
Date: Thu, 07 Mar 2013 15:19:14 -0500 (EST)
Message-ID: <20130307.151914.1226976697328075988.davem@redhat.com>
References: <1362654925-26088-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44694 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751364Ab3CGUTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Mar 2013 15:19:16 -0500
In-Reply-To: <1362654925-26088-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  7 Mar 2013 03:15:22 -0800

> This series contains updates to e1000e only.
> 
> All three patches come from Konstantin Khlebnikov to resolve power
> management issues.  The first patch removes redundant and unbalanced
> pci_disable_device() from the shutdown function.  The second patch
> removes redundant actions from the driver and fixes the interaction
> with actions in pci-bus runtime power management code.  The third
> and last patch fixes some messages like 'Error reading PHY register'
> and 'Hardware Erorr' and saves several seconds on reboot.
> 
> The following are changes since commit f8af75f3517a24838a36eb5797a1a3e60bf9e276:
>   tun: add a missing nf_reset() in tun_net_xmit()
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net master

Pulled, thanks Jeff.
