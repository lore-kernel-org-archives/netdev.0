From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: fix state equivalence
Date: Thu, 08 Dec 2016 13:31:33 -0500 (EST)
Message-ID: <20161208.133133.498441460961253034.davem@davemloft.net>
References: <1481137079-2205635-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, jbacik@fb.com, tgraf@suug.ch,
        netdev@vger.kernel.org
To: ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752237AbcLHScR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Dec 2016 13:32:17 -0500
In-Reply-To: <1481137079-2205635-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@fb.com>
Date: Wed, 7 Dec 2016 10:57:59 -0800

> Commmits 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")
> and 484611357c19 ("bpf: allow access into map value arrays") by themselves
> are correct, but in combination they make state equivalence ignore 'id' field
> of the register state which can lead to accepting invalid program.
> 
> Fixes: 57a09bf0a416 ("bpf: Detect identical PTR_TO_MAP_VALUE_OR_NULL registers")
> Fixes: 484611357c19 ("bpf: allow access into map value arrays")
> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
