From: Andy Green <andy.green@linaro.org>
Subject: [PATCH 0/2] net: wireless: wcn36xx: OOT platform reference patch
 for msm8916 / wcn36xx
Date: Sun, 18 Jan 2015 13:16:39 +0800
Message-ID: <20150118051222.32019.32719.stgit@114-36-241-182.dynamic.hinet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>,
	Eugene Krasnikov <k.eugene.e@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34223 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750726AbbARFQq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 00:16:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are not intended for upstreaming.  They are
included as a reference to show how to hook up wcn36xx to
msm platforms using the OOT PIL support needed.

The following series adds Eugene's OOT msm platform shim to
wcn36xx and modifies it to provide wcn36xx platform data
about chip type from Device Tree.

It's useful as an example for how to implement on msm
platforms that do not have all the necessary support
upstreamed yet.

This was tested on msm8916-QRD "phone" dev platform.

---

Andy Green (1):
      net wireless wcn36xx adapt wcnss platform to select module by DT

Eugene Krasnikov (1):
      net wireless wcn36xx add wcnss platform code


 drivers/net/wireless/ath/wcn36xx/Makefile      |    2 
 drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c |  360 ++++++++++++++++++++++++
 2 files changed, 361 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/wireless/ath/wcn36xx/wcn36xx-msm.c

--
