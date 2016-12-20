From: Dongpo Li <lidongpo@hisilicon.com>
Subject: [PATCH 0/2] net: hix5hd2_gmac: keep the compatible string not changed
Date: Tue, 20 Dec 2016 10:09:27 +0800
Message-ID: <1482199769-106501-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng@hisilicon.com>, <benjamin.chenhao@hisilicon.com>,
        <caizhiyong@hisilicon.com>, <netdev@vger.kernel.org>,
        <devicetree@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        Dongpo Li <lidongpo@hisilicon.com>
To: <robh+dt@kernel.org>, <mark.rutland@arm.com>,
        <linux@armlinux.org.uk>, <yisen.zhuang@huawei.com>,
        <salil.mehta@huawei.com>, <davem@davemloft.net>, <arnd@arndb.de>,
        <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series fix the patch:
d0fb6ba75dc0 ("net: hix5hd2_gmac: add generic compatible string")

The SoC hix5hd2 compatible string has the suffix "-gmac" and
we should not change its compatible string.
So we should name all the compatible string with the suffix "-gmac".
Creating a new name suffix "-gemac" is unnecessary.

Dongpo Li (2):
  net: hix5hd2_gmac: fix compatible strings name
  ARM: dts: hix5hd2: don't change the existing compatible string

 .../devicetree/bindings/net/hisilicon-hix5hd2-gmac.txt      | 13 ++++++++-----
 arch/arm/boot/dts/hisi-x5hd2.dtsi                           |  4 ++--
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c               | 13 +++++++------
 3 files changed, 17 insertions(+), 13 deletions(-)

-- 
2.8.2
