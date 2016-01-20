From: Jisheng Zhang <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 0/4] net: mvneta: support more than one clk
Date: Wed, 20 Jan 2016 16:06:19 +0800
Message-ID: <1453277183-5412-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Jisheng Zhang <jszhang-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<mw-nYOzD4b6Jr9Wk0Htik3J/w@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Some platforms may provide more than one clk for the mvneta IP, for
example Marvell BG4CT provides "core" clk for the mac core, and "axi"
clk for the AXI bus logic.

This series tries to addess the "more than one clk" issue. Note: to
support BG4CT, we have lots of refactor work to do, eg. BG4CT doesn't
have mbus concept etc.

Jisheng Zhang (4):
  net: mvneta: sort the headers in alphabetic order
  net: mvneta: Try to get named core clock first
  net: mvneta: mmc: get optional axi clk
  net: mvneta: update clocks property and document additional
    clock-names

 .../bindings/net/marvell-armada-370-neta.txt       |  6 +++-
 drivers/net/ethernet/marvell/mvneta.c              | 36 ++++++++++++++--------
 2 files changed, 28 insertions(+), 14 deletions(-)

-- 
2.7.0.rc3

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
