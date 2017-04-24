From: Paul Menzel <pmenzel@molgen.mpg.de>
Subject: Re: [Intel-wired-lan] [PATCH 1/2] e1000e: Don't return uninitialized
 stats
Date: Mon, 24 Apr 2017 10:23:48 +0200
Message-ID: <71d8032d-5ed1-8242-83e6-16ce65718966@molgen.mpg.de>
References: <20170421212012.25950-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org,
        Stefan Priebe <s.priebe@profihost.ag>
To: Benjamin Poirier <bpoirier@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.molgen.mpg.de ([141.14.17.11]:35402 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1166622AbdDXIXu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 04:23:50 -0400
In-Reply-To: <20170421212012.25950-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Benjamin,


Thank you for your fix.

On 04/21/17 23:20, Benjamin Poirier wrote:
> Some statistics passed to ethtool are garbage because e1000e_get_stats64()
> doesn't write them, for example: tx_heartbeat_errors. This leaks kernel
> memory to userspace and confuses users.

Could you please give specific examples to reproduce the issue? That way 
your fix can also be tested.

[…]


Kind regards,

Paul
