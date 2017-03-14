From: Sean Wang <sean.wang@mediatek.com>
Subject: Re: [PATCH net-next 2/4] net-next: dsa: add Mediatek tag RX/TX
 handler
Date: Tue, 14 Mar 2017 14:22:10 +0800
Message-ID: <1489472530.1870.21.camel@mtkswgap22>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com>
         <1489421488-300-3-git-send-email-sean.wang@mediatek.com>
         <87innd6rk2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <matthias.bgg@gmail.com>,
        <robh+dt@kernel.org>, <mark.rutland@arm.com>,
        <devicetree@vger.kernel.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <davem@davemloft.net>,
        <Landen.Chao@mediatek.com>, <keyhaede@gmail.com>,
        <objelf@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87innd6rk2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2017-03-13 at 12:59 -0400, Vivien Didelot wrote:
> Hi Sean,
> 
> sean.wang@mediatek.com writes:
> 
> > +	mtk_tag[1] = (1 << p->port) & MTK_HDR_XMIT_DP_BIT_MASK;
> 
> This won't apply, the port index in now stored in p->dp->index.
> 
> Thanks,
> 
>         Vivien


Hi Vivien,

It seems that I need to upgrade to newer kernel to verify this

thanks for your review , I'll fix this in the next one.

	Sean
