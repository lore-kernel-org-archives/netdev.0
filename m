From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/7][pull request] 1GbE Intel Wired LAN Driver
 Updates 2017-10-26
Date: Sat, 28 Oct 2017 00:15:43 +0900 (KST)
Message-ID: <20171028.001543.704160172511992127.davem@davemloft.net>
References: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51254 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751001AbdJ0PPs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 11:15:48 -0400
In-Reply-To: <20171026171714.45087-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 26 Oct 2017 10:17:07 -0700

> This patchset is a proposal of how the Traffic Control subsystem can
> be used to offload the configuration of the Credit Based Shaper
> (defined in the IEEE 802.1Q-2014 Section 8.6.8.2) into supported
> network devices.

Jeff, please collapse patch #6 into patch #4, as #6 fixes a bug added
by #4.

This will also help make things bisect better.

Thank you.
