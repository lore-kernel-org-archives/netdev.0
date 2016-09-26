From: Nelson Chang <nelson.chang@mediatek.com>
Subject: RE: [PATCH net-next 2/2] net: ethernet: mediatek: bug fix to
 disable HW LRO
Date: Mon, 26 Sep 2016 19:43:45 +0800
Message-ID: <1474890225.2669.4.camel@mtksdaap41>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <nelsonch.tw@gmail.com>
To: <sergei.shtylyov@cogentembedded.com>, <john@phrozen.org>,
        <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:14323 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S932843AbcIZLnv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 07:43:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

Because these modifications are both related to LRO relinquishments, I
put them in a single patch.


Nelson

-----Original Message-----
From: Sergei Shtylyov [mailto:sergei.shtylyov@cogentembedded.com] 
Sent: Monday, September 26, 2016 7:21 PM
To: Nelson Chang (張家祥); john@phrozen.org; davem@davemloft.net
Cc: nbd@openwrt.org; netdev@vger.kernel.org;
linux-mediatek@lists.infradead.org; nelsonch.tw@gmail.com
Subject: Re: [PATCH net-next 2/2] net: ethernet: mediatek: bug fix to
disable HW LRO

Hello.

On 9/26/2016 9:33 AM, Nelson Chang wrote:

> (1) Modify the register settings for LRO relinquishments
> (2) Jump out from the waiting loop while LRO relinquishments are done

    Why this is done in a single patch?

> Signed-off-by: Nelson Chang <nelson.chang@mediatek.com>
[...]

MBR, Sergei
