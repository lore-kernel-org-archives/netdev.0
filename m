From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Wed, 24 Feb 2010 22:41:39 -0500
Message-ID: <4B85F173.40703@garzik.org>
References: <20100204075101.16661.95658.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:61282 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758899Ab0BYDlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2010 22:41:42 -0500
Received: by gwj16 with SMTP id 16so1487894gwj.19
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2010 19:41:41 -0800 (PST)
In-Reply-To: <20100204075101.16661.95658.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/04/2010 02:51 AM, Jeff Kirsher wrote:
> From: Peter Waskiewicz<peter.p.waskiewicz.jr@intel.com>
>
> Program underlying ethernet devices with n-tuple flow classification
> filters.
>
> This also adds a new flag to ethtool_flags, allowing n-tuple
> programming to be toggled using the set_flags call.
>
> Signed-off-by: Peter P Waskiewicz Jr<peter.p.waskiewicz.jr@intel.com>
> Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
> ---
>
>   ethtool-copy.h |   35 +++++++++++++
>   ethtool.c      |  156 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
>   2 files changed, 186 insertions(+), 5 deletions(-)

applied, but two problems remain:

1) you failed to document this in the man page.  I will expect a patch 
to ethtool.8.

2) you introduced a deviation from the upstream kernel ethtool.h:


--- ethtool-copy.h      2010-02-24 22:39:21.000000000 -0500
+++ ../net-next-2.6/include/linux/ethtool.h     2010-02-24 
22:14:43.000000000 -0500
@@ -389,8 +389,6 @@
  #define ETHTOOL_RXNTUPLE_ACTION_DROP -1
  };

-#define ETHTOOL_MAX_NTUPLE_LIST_ENTRY 1024
-#define ETHTOOL_MAX_NTUPLE_STRING_PER_ENTRY 14
  struct ethtool_rx_ntuple {
         __u32                                   cmd;
         struct ethtool_rx_ntuple_flow_spec      fs;


