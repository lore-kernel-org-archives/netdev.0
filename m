From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] net: sched: fix tc_should_offload for specific clsact
 classes
Date: Tue, 7 Jun 2016 08:31:10 -0700
Message-ID: <5756E8BE.7090503@gmail.com>
References: <6eb47dcc252d843d7338ce2c9b98f667b45c8450.1465245985.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34977 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647AbcFGPbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 11:31:22 -0400
Received: by mail-pa0-f49.google.com with SMTP id xk1so46985805pac.2
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 08:31:21 -0700 (PDT)
In-Reply-To: <6eb47dcc252d843d7338ce2c9b98f667b45c8450.1465245985.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-06 01:50 PM, Daniel Borkmann wrote:
> When offloading classifiers such as u32 or flower to hardware, and the
> qdisc is clsact (TC_H_CLSACT), then we need to differentiate its classes,
> since not all of them handle ingress, therefore we must leave those in
> software path. Add a .tcf_cl_offload() callback, so we can generically
> handle them, tested on ixgbe.
> 
> Fixes: 10cbc6843446 ("net/sched: cls_flower: Hardware offloaded filters statistics support")
> Fixes: 5b33f48842fa ("net/flower: Introduce hardware offload support")
> Fixes: a1b7c5fd7fe9 ("net: sched: add cls_u32 offload hooks for netdevs")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---

Looks good to me. Thanks!

Acked-by: John Fastabend <john.r.fastabend@intel.com>
