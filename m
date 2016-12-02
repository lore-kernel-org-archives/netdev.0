From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Avoid deadlock situation due to use of xmit_lock
Date: Sat,  3 Dec 2016 00:06:04 +0100
Message-ID: <1480719966-12839-1-git-send-email-LinoSanfilippo@gmx.de>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: bh74.an@samsung.com, ks.giri@samsung.com, vipul.pandya@samsung.com,
        peppe.cavallaro@st.com, alexandre.torgue@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

after stumbling over a potential deadlock situation in the altera driver 
(see http://marc.info/?l=linux-netdev&m=148054615230447&w=2), I checked
all other ethernet drivers for the same issue and actually found it in 2
more, namely stmmac, and sxgbe. Please see the commit messages for a 
description of the problem.
These 2 patches fix the concerning drivers.

Regards,
Lino
