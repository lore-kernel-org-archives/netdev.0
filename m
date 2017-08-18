From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Fix map-in-map checking in the verifier
Date: Fri, 18 Aug 2017 16:26:02 -0700 (PDT)
Message-ID: <20170818.162602.1240356399178447885.davem@davemloft.net>
References: <20170818011443.562793-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com, john.fastabend@gmail.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34848 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751575AbdHRX0D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:26:03 -0400
In-Reply-To: <20170818011443.562793-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 17 Aug 2017 18:14:43 -0700

> In check_map_func_compatibility(), a 'break' has been accidentally
> removed for the BPF_MAP_TYPE_ARRAY_OF_MAPS and BPF_MAP_TYPE_HASH_OF_MAPS
> cases.  This patch adds it back.
> 
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied.
