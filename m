From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: use prefix_len in test_tag when reading
 fdinfo
Date: Wed, 25 Jan 2017 23:15:39 -0500 (EST)
Message-ID: <20170125.231539.610771035278620989.davem@davemloft.net>
References: <a4146cba5583102419763e59d8feff5e91802525.1485387682.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752746AbdAZEPk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 23:15:40 -0500
In-Reply-To: <a4146cba5583102419763e59d8feff5e91802525.1485387682.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 26 Jan 2017 00:42:49 +0100

> We currently used len instead of prefix_len for the strncmp() in
> fdinfo on the prog_tag. It still worked as we matched on the correct
> output line also with first 8 instead of 10 chars, but lets fix it
> properly to use the intended length.
> 
> Fixes: 62b64660262a ("bpf: add prog tag test case to bpf selftests")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Alexei Starovoitov <ast@kernel.org>

Applied.
