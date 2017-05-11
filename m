From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 2/7] bpf: Do per-instruction state dumping in verifier
 when log_level > 1.
Date: Thu, 11 May 2017 18:40:04 +0200
Message-ID: <591493E4.1090303@iogearbox.net>
References: <20170511.120529.492579439081538459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54571 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933159AbdEKQkK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 12:40:10 -0400
In-Reply-To: <20170511.120529.492579439081538459.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2017 06:05 PM, David Miller wrote:
>
> If log_level > 1, do a state dump every instruction and emit it in
> a more compact way (without a leading newline).
>
> This will facilitate more sophisticated test cases which inspect the
> verifier log for register state.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
