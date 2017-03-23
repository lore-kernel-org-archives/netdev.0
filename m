From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: stmmac: Performance regression after commit aff3d9eff843 "net:
 stmmac: enable multiple buffers"
Date: Thu, 23 Mar 2017 11:08:28 +0100
Message-ID: <20170323100828.GC16625@Red>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Joao.Pinto@synopsys.com, peppe.cavallaro@st.com,
        alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:34261 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751538AbdCWKIf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 06:08:35 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello

Using next-20170323 produce a huge performance regression on my sunxi boards.
On dwmac-sun8i, iperf goes from 94mbs/s to 37 when sending.

On cubieboard2(dwmac-sunxi), iperf made the kernel flood with "ndesc_get_rx_status: Oversized frame spanned multiple buffers"
and network is lost after.

Reverting aff3d9eff84399e433c4aca65a9bb236581bc082 fix the issue.
I still try to found which part of this patch mades the performance lower.

Regards
Corentin Labbe
