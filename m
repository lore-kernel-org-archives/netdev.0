From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tools: bpftool: try to mount bpffs if
 required for pinning objects
Date: Thu, 26 Oct 2017 17:53:33 +0900 (KST)
Message-ID: <20171026.175333.1830367025144925809.davem@davemloft.net>
References: <20171025031128.13990-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        quentin.monnet@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59616 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750884AbdJZIxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 04:53:37 -0400
In-Reply-To: <20171025031128.13990-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 24 Oct 2017 20:11:28 -0700

> From: Quentin Monnet <quentin.monnet@netronome.com>
> 
> One possible cause of failure for `bpftool {prog|map} pin * file FILE`
> is the FILE not being in an eBPF virtual file system (bpffs). In this
> case, make bpftool attempt to mount bpffs on the parent directory of the
> FILE. Then, if this operation is successful, try again to pin the
> object.
> 
> The code for mnt_bpffs() is a copy of function bpf_mnt_fs() from
> iproute2 package (under lib/bpf.c, taken at commit 4b73d52f8a81), with
> modifications regarding handling of error messages.
> 
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied.
