From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 2/3] bpf: Add uniqueness invariant to trivial
 lpm test implementation
Date: Tue, 19 Sep 2017 18:12:34 +0200
Message-ID: <59C141F2.10104@iogearbox.net>
References: <20170918193057.37644-1-kraigatgoog@gmail.com> <20170918193057.37644-3-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Craig Gallek <kraigatgoog@gmail.com>,
        Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47143 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751396AbdISQMi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 12:12:38 -0400
In-Reply-To: <20170918193057.37644-3-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2017 09:30 PM, Craig Gallek wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
