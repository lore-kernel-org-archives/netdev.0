From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf, lpm: fix kfree of im_node in
 trie_update_elem
Date: Mon, 23 Jan 2017 16:37:09 -0800
Message-ID: <20170124003707.GA60699@ast-mbp.thefacebook.com>
References: <6052894aa1bd4df5a5c7aaa05f5b63a980cbe371.1485217298.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, ast@kernel.org, daniel@zonque.org,
        netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33449 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbdAXAhO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:37:14 -0500
Received: by mail-pf0-f195.google.com with SMTP id e4so10885821pfg.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 16:37:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <6052894aa1bd4df5a5c7aaa05f5b63a980cbe371.1485217298.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 24, 2017 at 01:26:46AM +0100, Daniel Borkmann wrote:
> We need to initialize im_node to NULL, otherwise in case of error path
> it gets passed to kfree() as uninitialized pointer.
> 
> Fixes: b95a5c4db09b ("bpf: add a longest prefix match trie map implementation")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Great catch.
Acked-by: Alexei Starovoitov <ast@kernel.org>
