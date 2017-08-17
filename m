From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: no need to nullify ri->map in
 xdp_do_redirect
Date: Thu, 17 Aug 2017 10:16:31 -0700 (PDT)
Message-ID: <20170817.101631.1454679823951159481.davem@davemloft.net>
References: <782d0b6850cb1a63230c0fd634f1e61d67a01e60.1502975082.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.fastabend@gmail.com, ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59966 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753497AbdHQRQc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 13:16:32 -0400
In-Reply-To: <782d0b6850cb1a63230c0fd634f1e61d67a01e60.1502975082.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 17 Aug 2017 15:07:22 +0200

> We are guaranteed to have a NULL ri->map in this branch since
> we test for it earlier, so we don't need to reset it here.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
