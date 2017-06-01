From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH net-next 2/2] bpf: Remove the capability check for
 cgroup skb eBPF program
Date: Thu, 1 Jun 2017 00:17:15 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15BB37ED@cnshjmbx02>
References: <1496254013-18719-1-git-send-email-chenbofeng.kernel@gmail.com>
 <1496254013-18719-2-git-send-email-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Lorenzo Colitti <lorenzo@google.com>,
        Chenbo Feng <fengc@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:63398 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751015AbdFAARV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 20:17:21 -0400
In-Reply-To: <1496254013-18719-2-git-send-email-chenbofeng.kernel@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Chenbo Feng
> Sent: Thursday, June 01, 2017 2:07 AM
> To: netdev@vger.kernel.org; David Miller
> Cc: Lorenzo Colitti; Chenbo Feng
> Subject: [PATCH net-next 2/2] bpf: Remove the capability check for cgroup skb
> eBPF program
> -	if (type != BPF_PROG_TYPE_SOCKET_FILTER
> && !capable(CAP_SYS_ADMIN))
> +	if (type != BPF_PROG_TYPE_SOCKET_FILTER
> +	    && type != BPF_PROG_TYPE_CGROUP_SKB
> +	    && !capable(CAP_SYS_ADMIN))

checkpatch.pl prefer put && at end of line

>  		return -EPERM;
> 
>  	/* plain bpf_prog allocation */
> --
> 2.7.4
