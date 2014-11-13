From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/3] sh_eth: Remove redundant alignment adjustment
Date: Fri, 14 Nov 2014 01:37:22 +0300
Message-ID: <546532A2.80509@cogentembedded.com>
References: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com> <1415862301-28032-2-git-send-email-ykaneko0929@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Simon Horman <horms@verge.net.au>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1415862301-28032-2-git-send-email-ykaneko0929@gmail.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/13/2014 10:04 AM, Yoshihiro Kaneko wrote:

> From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>

> PTR_ALIGN macro after skb_reserve is redundant, because skb_reserve
> function adjusts the alignment of skb->data.

    OK, but where is the bug? There must be one if you base this patch on the 
'net' tree...

> Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>

WBR, Sergei

