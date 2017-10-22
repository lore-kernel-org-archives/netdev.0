From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] bpf: add support for BASE_RTT
Date: Sun, 22 Oct 2017 03:12:23 +0100 (WEST)
Message-ID: <20171022.031223.683555755677968365.davem@davemloft.net>
References: <20171020180543.4156833-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ast@fb.com,
        daniel@iogearbox.net, bmatheny@fb.com
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57662 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932310AbdJVCM1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 22:12:27 -0400
In-Reply-To: <20171020180543.4156833-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Fri, 20 Oct 2017 11:05:38 -0700

> This patch set adds the following functionality to socket_ops BPF
> programs.
> 1) Add bpf helper function bpf_getsocketops. Currently only supports
>    TCP_CONGESTION
> 2) Add BPF_SOCKET_OPS_BASE_RTT op to get the base RTT of the
>    connection. In general, the base RTT indicates the threshold such
>    that RTTs above it indicate congestion. More details in the
>    relevant patches.   

Series applied, thank you.
