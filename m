From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: expose prog id for cls_bpf and act_bpf
Date: Wed, 21 Jun 2017 15:14:40 -0400 (EDT)
Message-ID: <20170621.151440.424326589634772993.davem@davemloft.net>
References: <66b50f95666de97e7f067471d409fce8d316ad43.1498068442.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, kafai@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43874 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751028AbdFUTOm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 15:14:42 -0400
In-Reply-To: <66b50f95666de97e7f067471d409fce8d316ad43.1498068442.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 21 Jun 2017 20:16:11 +0200

> In order to be able to retrieve the attached programs from cls_bpf
> and act_bpf, we need to expose the prog ids via netlink so that
> an application can later on get an fd based on the id through the
> BPF_PROG_GET_FD_BY_ID command, and dump related prog info via
> BPF_OBJ_GET_INFO_BY_FD command for bpf(2).
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks Daniel.
