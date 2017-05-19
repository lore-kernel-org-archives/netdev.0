From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] bpf: Use 1<<16 as ceiling for immediate
 alignment in verifier.
Date: Fri, 19 May 2017 16:41:54 -0400 (EDT)
Message-ID: <20170519.164154.368589666756458942.davem@davemloft.net>
References: <7402a02c-cb00-d48e-1d2a-ccb03356fb72@solarflare.com>
        <db8cd2e8-9f51-dc8b-5e55-4c75d13d4858@fb.com>
        <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, alexei.starovoitov@gmail.com,
        netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57418 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750943AbdESUmT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 16:42:19 -0400
In-Reply-To: <a0a47297-4765-3ba0-3ea2-013dda40e84a@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 19 May 2017 18:17:42 +0100

> One question: is there a way to build the verifier as userland code
>  (or at least as a module), or will I have to reboot every time I
>  want to test a change?

There currently is no such machanism, you will have to reboot every
time.

I have considered working on making the code buildable outside of the
kernel.  It shouldn't be too hard.
