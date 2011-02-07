From: "Tomoya MORINAGA" <tomoya-linux@dsn.okisemi.com>
Subject: About bittiming calculation result
Date: Mon, 7 Feb 2011 20:38:29 +0900
Message-ID: <5009516791F146C49C73FAC57C437313@hacdom.okisemi.com>
References: <cover.1296818921.git.segoon@openwall.com><a6800dc8b0daed78256f98f52844cbbb48f4a76d.1296818921.git.segoon@openwall.com><20110204124233.GB334@e-circ.dyndns.org> <20110204.130649.112613896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: <wg@grandegger.com>, <socketcan-core@lists.berlios.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110204.130649.112613896.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have a question for bittiming-value calculated by Can-core.

In case setting like below,
 - ip link set can0 type can bitrate 800000
 - clock=50MHz
 - Use pch_can

Can-core calculates like below
brp=21
seg1=1
seg2=1
sjw=1
prop_seg=0

Is "prop_seg=0" true ?
seg1/seg2/sjw/prop_seg must be more than 1 ?

Also I can see the following kernel error log.
bitrate error 0.7%

Thanks,
-----------------------------------------
Tomoya MORINAGA
OKI SEMICONDUCTOR CO., LTD.
