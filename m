From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: add additional verifier tests for
 BPF_PROG_TYPE_LWT_*
Date: Mon, 5 Dec 2016 08:33:31 -0800
Message-ID: <20161205163329.GA79989@ast-mbp.thefacebook.com>
References: <ad522c194cdc9b37a50ce087453586128e954321.1480926086.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32822 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752160AbcLEQdf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 11:33:35 -0500
Received: by mail-pg0-f65.google.com with SMTP id 3so16922719pgd.0
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 08:33:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <ad522c194cdc9b37a50ce087453586128e954321.1480926086.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 05, 2016 at 10:30:52AM +0100, Thomas Graf wrote:
>  - direct packet read is allowed for LWT_*
>  - direct packet write for LWT_IN/LWT_OUT is prohibited
>  - direct packet write for LWT_XMIT is allowed
>  - access to skb->tc_classid is prohibited for LWT_*
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Nice! Thanks for the test.
Acked-by: Alexei Starovoitov <ast@kernel.org>
