From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: linux-next-20170320 break stmmac on dwmac-sunxi
Date: Mon, 20 Mar 2017 20:54:06 +0100
Message-ID: <20170320195406.GA19174@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:35512 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756011AbdCTTy4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 15:54:56 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

Just pushed next-20170320 to my boards and stmmac stop working on both intree dwmac-sunxi and my dev dwmac-sun8i.
It seems that interrupts never fire, and transmit queue timeout.
I will try to bisect this problem but perhaps other people could try to reproduce it.

Regards
Corentin Labbe
