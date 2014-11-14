From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/3] sh_eth: Remove redundant alignment adjustment
Date: Fri, 14 Nov 2014 09:43:58 +0900
Message-ID: <20141114004358.GN14971@verge.net.au>
References: <1415862301-28032-1-git-send-email-ykaneko0929@gmail.com>
 <1415862301-28032-2-git-send-email-ykaneko0929@gmail.com>
 <546532A2.80509@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yoshihiro Kaneko <ykaneko0929@gmail.com>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Magnus Damm <magnus.damm@gmail.com>, linux-sh@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <546532A2.80509@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 14, 2014 at 01:37:22AM +0300, Sergei Shtylyov wrote:
> On 11/13/2014 10:04 AM, Yoshihiro Kaneko wrote:
> 
> >From: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> 
> >PTR_ALIGN macro after skb_reserve is redundant, because skb_reserve
> >function adjusts the alignment of skb->data.
> 
>    OK, but where is the bug? There must be one if you base this patch on the
> 'net' tree...

I suppose this patch would be more appropriate for the net-next tree.

> >Signed-off-by: Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>
> >Signed-off-by: Yoshihiro Kaneko <ykaneko0929@gmail.com>
> 
> WBR, Sergei
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
