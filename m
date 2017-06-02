From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 00/14][pull request] 40GbE Intel Wired LAN Driver
 Updates 2017-06-01
Date: Fri, 02 Jun 2017 13:54:12 -0400 (EDT)
Message-ID: <20170602.135412.1859783191502215685.davem@davemloft.net>
References: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45748 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdFBRyQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Jun 2017 13:54:16 -0400
In-Reply-To: <20170601213840.36286-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu,  1 Jun 2017 14:38:26 -0700

> This series contains updates to i40e, i40evf and the "new" AVF virtchnl.
> 
> This is the introduction of the Intel(R) Ethernet Adaptive Virtual
> Function driver code and device ID, as presented at the NetDEV 1.2
> conference in 2016.
> http://netdevconf.org/1.2/session.html?anjali-singhai
> 
> The idea is to convert the interface between the i40evf driver
> and the parent i40e PF driver to be generic, as the i40evf driver
> should in the future be able to run on top of other Intel PF
> drivers, and negotiate any features beyond a "base expected" set.
> 
> The following are changes since commit 0266f79778de0afadd070941aae493c28529d974:
>   mlxsw: spectrum: Add bridge dependency for spectrum
> and are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 40GbE

Ok, doesn't look too bad.

I might have preferred if patch #11 used a compile time BUILD_BUG_ON()
of some sort in a core init function or similar.  But I can understand
the desire to use a scheme that allows annotations right next to the
datastructure definitions themselves.

Pulled, th anks.
