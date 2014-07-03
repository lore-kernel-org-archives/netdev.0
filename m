From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 1/2] bridge: fdb dumping takes a filter
 device
Date: Thu, 03 Jul 2014 17:53:40 +0530
Message-ID: <53B54B4C.8080003@gmail.com>
References: <1404380290-17040-1-git-send-email-jhs@emojatatu.com> <1404380290-17040-2-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com,
	sfeldma@cumulusnetworks.com, john.r.fastabend@intel.com,
	roopa@cumulusnetworks.com, eric.dumazet@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>, davem@davemloft.net,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:60341 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750924AbaGCMYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2014 08:24:50 -0400
Received: by mail-pd0-f170.google.com with SMTP id z10so145041pdj.1
        for <netdev@vger.kernel.org>; Thu, 03 Jul 2014 05:24:49 -0700 (PDT)
In-Reply-To: <1404380290-17040-2-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2014 03:08 PM, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Dumping a bridge fdb dumps every fdb entry
> held. With this change we are going to filter
> on selected bridge port.
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>   drivers/net/ethernet/intel/i40e/i40e_main.c      |    3 ++-
>   drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    7 ++++---
>   include/linux/netdevice.h                        |    1 +
>   include/linux/rtnetlink.h                        |    1 +
>   net/bridge/br_fdb.c                              |    5 +++++
>   net/bridge/br_private.h                          |    2 +-
>   net/core/rtnetlink.c                             |    7 ++++---
>   7 files changed, 18 insertions(+), 8 deletions(-)
>
>
[...]

checkpatch.pl is giving the following warnings on this patch

WARNING: line over 80 characters
#30: FILE: drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c:430:
+			struct net_device *netdev, struct net_device *filter_dev,

WARNING: line over 80 characters
#123: FILE: net/core/rtnetlink.c:2551:
+				idx = ops->ndo_fdb_dump(skb, cb, dev, NULL, idx);

WARNING: line over 80 characters
#128: FILE: net/core/rtnetlink.c:2555:
+			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, dev, NULL, idx);

total: 0 errors, 3 warnings, 0 checks, 97 lines checked

-- 
Varka Bhadram
