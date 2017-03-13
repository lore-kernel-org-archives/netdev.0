From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 2/4] net-next: dsa: add Mediatek tag RX/TX handler
Date: Mon, 13 Mar 2017 12:59:41 -0400
Message-ID: <87innd6rk2.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
References: <1489421488-300-1-git-send-email-sean.wang@mediatek.com> <1489421488-300-3-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: devicetree@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        davem@davemloft.net, sean.wang@mediatek.com,
        Landen.Chao@mediatek.com, keyhaede@gmail.com, objelf@gmail.com
To: sean.wang@mediatek.com, andrew@lunn.ch, f.fainelli@gmail.com,
        matthias.bgg@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:37014 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752002AbdCMRBT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 13:01:19 -0400
In-Reply-To: <1489421488-300-3-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sean,

sean.wang@mediatek.com writes:

> +	mtk_tag[1] = (1 << p->port) & MTK_HDR_XMIT_DP_BIT_MASK;

This won't apply, the port index in now stored in p->dp->index.

Thanks,

        Vivien
