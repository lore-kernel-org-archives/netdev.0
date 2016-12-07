From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Remove private locks to avoid possible deadlock
Date: Wed,  7 Dec 2016 21:05:36 +0100
Message-ID: <1481141138-19466-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: pavel@ucw.cz, davem@davemloft.net, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.20]:54969 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932209AbcLGUGS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 15:06:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

these patches fix possible deadlock situations in the sxgbe and stmmac
driver. Please note that the patches are only compile tested so it would
be great if someone could do tests with the concerning HW.

Regards,
Lino
