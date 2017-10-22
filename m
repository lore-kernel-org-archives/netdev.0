From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] Two BPF fixes for range marking
Date: Sun, 22 Oct 2017 01:13:46 +0100 (WEST)
Message-ID: <20171022.011346.2270067847397243642.davem@davemloft.net>
References: <cover.1508545543.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, john.r.fastabend@gmail.com,
        netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56476 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932261AbdJVANt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 20:13:49 -0400
In-Reply-To: <cover.1508545543.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sat, 21 Oct 2017 02:34:20 +0200

> The set contains two fixes for direct packet access range
> markings and test cases for all direct packet access patterns
> that the verifier matches on.
> 
> They are targeted for net tree, note that once net gets merged
> into net-next, there will be a minor merge conflict due to
> signature change of the function find_good_pkt_pointers() as
> well as data_meta patterns present in net-next tree. You can
> just add bool false to the data_meta patterns and I will
> follow-up with properly converting the patterns for data_meta
> in a similar way.

Series applied and thanks for the merge info.
