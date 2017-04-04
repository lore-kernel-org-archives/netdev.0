From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/3] flowcache: more "unsigned int"
Date: Mon, 03 Apr 2017 19:05:21 -0700 (PDT)
Message-ID: <20170403.190521.1373022319122803494.davem@davemloft.net>
References: <20170402215150.GA8938@avx2>
        <20170402215315.GC8938@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752482AbdDDCFW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Apr 2017 22:05:22 -0400
In-Reply-To: <20170402215315.GC8938@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 3 Apr 2017 00:53:15 +0300

> Make ->hash_count, ->low_watermark and ->high_watermark unsigned int
> and propagate unsignedness to other variables.
> 
> This change doesn't change code generation because these fields aren't
> used in 64-bit contexts but make it anyway: these fields can't be
> negative numbers.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
