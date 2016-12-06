From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: add additional verifier tests for
 BPF_PROG_TYPE_LWT_*
Date: Tue, 06 Dec 2016 10:15:24 -0500 (EST)
Message-ID: <20161206.101524.1235882035561176567.davem@davemloft.net>
References: <ad522c194cdc9b37a50ce087453586128e954321.1480926086.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41452 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753518AbcLFPPb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 10:15:31 -0500
In-Reply-To: <ad522c194cdc9b37a50ce087453586128e954321.1480926086.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Mon,  5 Dec 2016 10:30:52 +0100

>  - direct packet read is allowed for LWT_*
>  - direct packet write for LWT_IN/LWT_OUT is prohibited
>  - direct packet write for LWT_XMIT is allowed
>  - access to skb->tc_classid is prohibited for LWT_*
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thank you.
