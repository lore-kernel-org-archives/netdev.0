From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 2/2] bpf: Align packet data properly in program testing
 framework.
Date: Tue, 02 May 2017 17:41:56 +0200
Message-ID: <5908A8C4.2040804@iogearbox.net>
References: <20170502.113645.551424261592586390.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36428 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbdEBPmF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:42:05 -0400
In-Reply-To: <20170502.113645.551424261592586390.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2017 05:36 PM, David Miller wrote:
>
> Make sure we apply NET_IP_ALIGN when reserving headroom for SKB
> and XDP test runs, just like a real driver would.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Thanks for fixing!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
