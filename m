From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v2 3/8] net: sched: add cls_u32 offload hooks
 for netdevs
Date: Tue, 16 Feb 2016 21:20:49 +0100
Message-ID: <20160216202049.GC2246@nanopsycho.orion>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
 <20160216060125.32452.25924.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:32834 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755854AbcBPUUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:20:51 -0500
Received: by mail-wm0-f42.google.com with SMTP id g62so208123355wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 12:20:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160216060125.32452.25924.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 16, 2016 at 07:01:25AM CET, john.fastabend@gmail.com wrote:
>This patch allows netdev drivers to consume cls_u32 offloads via
>the ndo_setup_tc ndo op.
>
>This works aligns with how network drivers have been doing qdisc
>offloads for mqprio.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

<snip>

>+struct tc_cls_u32_hnode {
>+	u32 handle;
>+	u32 prio;
>+	unsigned int divisor;
>+};
>+
>+enum {

Please name enum and ...

>+	TC_CLSU32_NEW_KNODE,
>+	TC_CLSU32_REPLACE_KNODE,
>+	TC_CLSU32_DELETE_KNODE,
>+	TC_CLSU32_NEW_HNODE,
>+	TC_CLSU32_REPLACE_HNODE,
>+	TC_CLSU32_DELETE_HNODE,
>+};
>+
>+struct tc_cls_u32_offload {
>+	/* knode values */
>+	int command;

... use it here instead of "int"
