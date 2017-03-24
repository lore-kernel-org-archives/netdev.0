From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: do not reset Octeon if NIC firmware
 was preloaded
Date: Fri, 24 Mar 2017 13:20:59 -0700 (PDT)
Message-ID: <20170324.132059.1978744476466250237.davem@davemloft.net>
References: <20170323202628.GA1090@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44080 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755962AbdCXUVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 16:21:01 -0400
In-Reply-To: <20170323202628.GA1090@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Thu, 23 Mar 2017 13:26:28 -0700

> The PF driver is incorrectly resetting Octeon when the module parameter
> "fw_type=none" is there.  "fw_type=none" means the PF should not load any
> firmware to the NIC because Octeon is already running preloaded firmware.
> 
> Fix it by putting an if (fw_type != none) around the reset code.
> 
> Because the Octeon reset is now conditionally gone, when unloading the
> driver, conditionally send the RESET_PF command to the firmware who will
> then free up PF-related data structures.
> 
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
> Signed-off-by: Satanand Burla <satananda.burla@cavium.com>

Applied.
