From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] nfp: bpf: rename ALU_OP_NEG and support
 BPF_NEG
Date: Thu, 02 Nov 2017 16:47:48 +0900 (KST)
Message-ID: <20171102.164748.1852340900831595296.davem@davemloft.net>
References: <20171101173825.7008-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44788 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750883AbdKBHrx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:47:53 -0400
In-Reply-To: <20171101173825.7008-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed,  1 Nov 2017 10:38:23 -0700

> Jiong says:
> 
>   Compilers are starting to use BPF_NEG, for example LLVM. However, NFP
> does not support JITing it. This patch set adds this. Unit test is added
> as well.
> 
>   Meanwhile, the current NFP_ALU_NEG is actually doing bitwise NOT (one's
> complement) operation, so the name is misleading. This patch set corrects
> this.

Series applied, thanks.
