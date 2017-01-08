From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: change back to orig prog on too many passes
Date: Sun, 08 Jan 2017 17:00:49 -0500 (EST)
Message-ID: <20170108.170049.185525468870291040.davem@davemloft.net>
References: <ce21b137ee688d48859b8337b2b2aebb2c404b93.1483744629.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42540 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S968666AbdAHWAz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2017 17:00:55 -0500
In-Reply-To: <ce21b137ee688d48859b8337b2b2aebb2c404b93.1483744629.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat,  7 Jan 2017 00:26:33 +0100

> If after too many passes still no image could be emitted, then
> swap back to the original program as we do in all other cases
> and don't use the one with blinding.
> 
> Fixes: 959a75791603 ("bpf, x86: add support for constant blinding")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied and queued up for -stable, thanks Daniel.
