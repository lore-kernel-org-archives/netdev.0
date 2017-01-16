From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net v3] ravb: do not use zero-length alignment DMA
 descriptor
Date: Mon, 16 Jan 2017 16:01:49 +0300
Message-ID: <96396803-caac-13cd-3e17-f9d10fc608ad@cogentembedded.com>
References: <1484563521-12009-1-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Magnus Damm <magnus.damm@gmail.com>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Masaru Nagai <masaru.nagai.vx@renesas.com>
To: Simon Horman <horms+renesas@verge.net.au>,
        David Miller <davem@davemloft.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1484563521-12009-1-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/16/2017 01:45 PM, Simon Horman wrote:

> From: Masaru Nagai <masaru.nagai.vx@renesas.com>
>
> Due to alignment requirements of the hardware transmissions are split into
> two DMA descriptors, a small padding descriptor of 0 - 3 bytes in length
> followed by a descriptor for rest of the packet.
>
> In the case of IP packets the first descriptor will never be zero due to
> the way that the stack aligns buffers for IP packets. However, for non-IP
> packets it may be zero.
>
> In that case it has been reported that timeouts occur, presumably because
> transmission stops at the first zero-length DMA descriptor and thus the
> packet is not transmitted. However, in my environment a BUG is triggered as
> follows:
[...]

> Fixes: 2f45d1902acf ("ravb: minimize TX data copying")
> Signed-off-by: Masaru Nagai <masaru.nagai.vx@renesas.com
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

MBR, Sergei
