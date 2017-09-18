From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 2/3] bpf: Add uniqueness invariant to trivial lpm
 test implementation
Date: Mon, 18 Sep 2017 15:54:16 -0700
Message-ID: <3549dc98-7309-2460-ad2c-69e17a550070@fb.com>
References: <20170918193057.37644-1-kraigatgoog@gmail.com>
 <20170918193057.37644-3-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>,
        Daniel Mack <daniel@zonque.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:39485 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750772AbdIRWyh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 18:54:37 -0400
In-Reply-To: <20170918193057.37644-3-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/18/17 12:30 PM, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
>
> The 'trivial' lpm implementation in this test allows equivalent nodes
> to be added (that is, nodes consisting of the same prefix and prefix
> length).  For lookup operations, this is fine because insertion happens
> at the head of the (singly linked) list and the first, best match is
> returned.  In order to support deletion, the tlpm data structue must
> first enforce uniqueness.  This change modifies the insertion algorithm
> to search for equivalent nodes and remove them.  Note: the
> BPF_MAP_TYPE_LPM_TRIE already has a uniqueness invariant that is
> implemented as node replacement.
>
> Signed-off-by: Craig Gallek <kraig@google.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>
