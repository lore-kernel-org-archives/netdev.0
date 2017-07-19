From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] liquidio: avoid vm low memory crashes
Date: Wed, 19 Jul 2017 13:25:11 -0700 (PDT)
Message-ID: <20170719.132511.1266939689962983807.davem@davemloft.net>
References: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        ricardo.farrington@cavium.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46782 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753791AbdGSUZM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 16:25:12 -0400
In-Reply-To: <20170718004920.GA1541@felix-thinkpad.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Mon, 17 Jul 2017 17:49:20 -0700

> From: Rick Farrington <ricardo.farrington@cavium.com>
> 
> This patchset addresses issues brought about by low memory conditions
> in a VM.  These conditions were not seen when the driver was exercised
> normally.  Rather, they were brought about through manual fault injection.
> They are being included in the interest of hardening the driver against
> unforeseen circumstances.
> 
> 1. Fix GPF in octeon_init_droq(); zero the allocated block 'recv_buf_list'.
>    This prevents a GPF trying to access an invalid 'recv_buf_list[i]' entry
>    in octeon_droq_destroy_ring_buffers() if init didn't alloc all entries.
> 2. Don't dereference a NULL ptr in octeon_droq_destroy_ring_buffers().
> 3. For defensive programming, zero the allocated block 'oct->droq[0]' in
>    octeon_setup_output_queues() and 'oct->instr_queue[0]' in    
>    octeon_setup_instr_queues().
> 
> change log:
> V1 -> V2:
> 1. Corrected syntax in 'Subject' lines; no functional or code changes.

Series applied.  I removed the "[0]" in this commit log message.

Thanks.
