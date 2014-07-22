From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next v7 1/6] openvswitch: Allow each vport to have
 an array of 'port_id's.
Date: Tue, 22 Jul 2014 12:23:35 +0530
Message-ID: <53CE0A6F.9030403@gmail.com>
References: <1406010583-1746-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alex Wang <alexw@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:45310 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbaGVGzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2014 02:55:01 -0400
Received: by mail-pa0-f41.google.com with SMTP id rd3so10890711pab.14
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2014 23:55:01 -0700 (PDT)
In-Reply-To: <1406010583-1746-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/22/2014 11:59 AM, Pravin B Shelar wrote:
> From: Alex Wang <alexw@nicira.com>
>
> In order to allow handlers directly read upcalls from datapath,
> we need to support per-handler netlink socket for each vport in
> datapath.  This commit makes this happen.  Also, it is guaranteed
> to be backward compatible with previous branch.
>
> Signed-off-by: Alex Wang <alexw@nicira.com>
> Acked-by: Thomas Graf <tgraf@redhat.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>   include/uapi/linux/openvswitch.h | 13 ++++--
>   net/openvswitch/datapath.c       | 21 ++++++---
>   net/openvswitch/vport.c          | 99 +++++++++++++++++++++++++++++++++++++++-
>   net/openvswitch/vport.h          | 27 +++++++++--
>   4 files changed, 144 insertions(+), 16 deletions(-)

WARNING: line over 80 characters

#67: FILE: net/openvswitch/datapath.c:1635:

+        nla_put_string(skb, OVS_VPORT_ATTR_NAME, vport->ops->get_name(vport)))

WARNING: line over 80 characters

#99: FILE: net/openvswitch/datapath.c:1820:

+                           a[OVS_VPORT_ATTR_UPCALL_PID]);

WARNING: line over 80 characters

#226: FILE: net/openvswitch/vport.c:423:

+    return ids->ids[hash - ids->n_ids * reciprocal_divide(hash, ids->rn_ids)];

-- 
Regards,
Varka Bhadram.
