From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 3/4] net_sched: gred: fix qave reporting via netlink
Date: Thu, 13 Sep 2012 14:01:59 -0400
Message-ID: <50521F97.20503@mojatatu.com>
References: <1347549755-19438-1-git-send-email-david.ward@ll.mit.edu> <1347549755-19438-3-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bruce Osler <brosler@cisco.com>,
	Cyril Chemparathy <cyril@ti.com>
To: David Ward <david.ward@ll.mit.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:52856 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751897Ab2IMSCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 14:02:02 -0400
Received: by vcbfo13 with SMTP id fo13so2846819vcb.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 11:02:01 -0700 (PDT)
In-Reply-To: <1347549755-19438-3-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-09-13 11:22 AM, David Ward wrote:
> q->vars.qavg is a Wlog scaled value, but q->backlog is not. In order
> to pass q->vars.qavg as the backlog value, we need to un-scale it.
> Additionally, the qave value returned via netlink should not be Wlog
> scaled, so we need to un-scale the result of red_calc_qavg().
>
> This caused artificially high values for "Average Queue" to be shown
> by 'tc -s -d qdisc', but did not affect the actual operation of GRED.
>
> Signed-off-by: David Ward <david.ward@ll.mit.edu>

Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
