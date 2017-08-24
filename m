From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] bpf: verifier fixes
Date: Wed, 23 Aug 2017 22:38:24 -0700 (PDT)
Message-ID: <20170823.223824.351616219178729814.davem@davemloft.net>
References: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, ast@fb.com, daniel@iogearbox.net,
        netdev@vger.kernel.org, iovisor-dev@lists.iovisor.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60872 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdHXFiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 01:38:25 -0400
In-Reply-To: <f9208b68-466e-c6cb-4d0c-c567e40bdc15@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Wed, 23 Aug 2017 15:07:20 +0100

> Fix a couple of bugs introduced in my recent verifier patches.
> Patch #2 does slightly increase the insn count on bpf_lxc.o, but only by
>  about a hundred insns (i.e. 0.2%).
> 
> v2: added test for write-marks bug (patch #1); reworded comment on
>  propagate_liveness() for clarity.

Series applied, thanks Edward.
