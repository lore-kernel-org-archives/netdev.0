From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/5] bpf: Do per-instruction state dumping in verifier
 when log_level > 1.
Date: Thu, 11 May 2017 14:42:48 +0200
Message-ID: <59145C48.10109@iogearbox.net>
References: <20170510.150947.1771591614496655880.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45543 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753303AbdEKMmy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 08:42:54 -0400
In-Reply-To: <20170510.150947.1771591614496655880.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/10/2017 09:09 PM, David Miller wrote:
>
> If log_level > 1, do a state dump every instruction and emit it in
> a more compact way (without a leading newline).
>
> This will facilitate more sophisticated test cases which inspect the
> verifier log for register state.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
