From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] samples/bpf: fix a build problem
Date: Thu, 22 Jun 2017 11:36:02 -0400 (EDT)
Message-ID: <20170622.113602.1678719803845495653.davem@davemloft.net>
References: <20170621204827.3259191-1-yhs@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        kernel-team@fb.com
To: yhs@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36356 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751458AbdFVPgE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:36:04 -0400
In-Reply-To: <20170621204827.3259191-1-yhs@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yonghong Song <yhs@fb.com>
Date: Wed, 21 Jun 2017 13:48:27 -0700

> tracex5_kern.c build failed with the following error message:
>   ../samples/bpf/tracex5_kern.c:12:10: fatal error: 'syscall_nrs.h' file not found
>   #include "syscall_nrs.h"
> The generated file syscall_nrs.h is put in build/samples/bpf directory,
> but this directory is not in include path, hence build failed.
> 
> The fix is to add $(obj) into the clang compilation path.
> 
> Signed-off-by: Yonghong Song <yhs@fb.com>

Applied, thanks.

Please be clear in the future that your patch is targetting 'net-next' by
specifying this in your subject lines:

	[PATCH net-next] ...

I had to figure this out by hand.

Thank you.
