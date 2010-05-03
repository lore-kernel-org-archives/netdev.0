From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH v3] ixgbe: disable MSI-X by default on
	certain Cisco adapters
Date: Mon, 3 May 2010 15:16:07 -0700
Message-ID: <w2u9929d2391005031516m6ae1bb3bpb9b4b9dc84bf4b1d@mail.gmail.com>
References: <20100428024521.28991.37874.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f203.google.com ([209.85.223.203]:44324 "EHLO
	mail-iw0-f203.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758534Ab0ECWVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 18:21:40 -0400
Received: by iwn41 with SMTP id 41so3774714iwn.20
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 15:21:39 -0700 (PDT)
In-Reply-To: <20100428024521.28991.37874.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave please revert the following patch because it is being fixed
without a software workaround:

commit d5ffd75a27fade39ba5df3b07290c5a2c297b9bd
Author: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Date:   Tue Apr 27 19:47:49 2010 -0700

    ixgbe: disable MSI-X by default on certain Cisco adapters

    Due to an errata in 82598 parts MSI-X needs to be disabled
    in certain ixgbe devices designed to transfer peer-to-peer
    traffic on the PCIe bus. This patch sets the default
    interrupt type to MSI rather than MSI-X for specific Cisco
    ixgbe adapters.

    Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
    Acked-by: John Ronciak <john.ronciak@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

-- 
Cheers,
Jeff
