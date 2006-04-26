From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH] e1000: skb truesize fix
Date: Tue, 25 Apr 2006 23:12:30 -0700
Message-ID: <20060426061229.25966.83974.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, "Miller, David" <davem@davemloft.net>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:9477 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S1750767AbWDZGMZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2006 02:12:25 -0400
To: stable@kernel.org, "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

This patch was already merged in Jeff Garzik's netdev upstream branch but
needs to go into 12.6.16.y and 2.6.17rc* as it fixes a critical buffersize
skb bug that is exposed by an earlier patch by Dave Miller and Herbert
Xiu. I'm therefore resending it:

Please apply to 2.6.16.y and queue for 2.6.17-rc.

These changes are available through git. Jeff, please pull from:

git://lost.foo-projects.org/~ahkok/git/linux-2.6 skb_truesize

these patches are against
 linux-2.6.git#master 4d5c34ec7b007cfb0771a36996b009f194acbb2f


Cheers,

Auke Kok


---
 drivers/net/e1000/e1000_main.c |    1 +
 1 files changed, 1 insertion(+)


--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro(R) Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
