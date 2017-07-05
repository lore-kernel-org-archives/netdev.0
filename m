From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] bpf: fix return in load_bpf_file
Date: Wed, 05 Jul 2017 09:05:46 +0100 (WEST)
Message-ID: <20170705.090546.645154914190164159.davem@davemloft.net>
References: <20170704225750.125603-1-brakmo@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com, ast@fb.com,
        daniel@iogearbox.net
To: brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752185AbdGEIFz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 04:05:55 -0400
In-Reply-To: <20170704225750.125603-1-brakmo@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lawrence Brakmo <brakmo@fb.com>
Date: Tue, 4 Jul 2017 15:57:50 -0700

> The function load_bpf_file ignores the return value of
> load_and_attach(), so even if load_and_attach() returns an error,
> load_bpf_file() will return 0.
> 
> Now, load_bpf_file() can call load_and_attach() multiple times and some
> can succeed and some could fail. I think the correct behavor is to
> return error on the first failed load_and_attach().
> 
> v2: Added missing SOB
> 
> Signed-off-by: Lawrence Brakmo <brakmo@fb.com>

Applied.
