From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 0/2] e1000: fix two mispatches
Date: Tue, 18 Apr 2006 12:39:50 -0700
Message-ID: <20060418193950.16262.10757.stgit@gitlost.site>
Cc: "Ronciak, John" <john.ronciak@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeff" <Jeffrey.t.kirsher@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:517 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932297AbWDRTgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2006 15:36:49 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	"Miller, David" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

This patch series implements two e100 fixes for an old and new patch mishap.

[1] fix mispatch for media type detect.
[2] fix mismerge skb_put.


These changes are available through git.

git://63.64.152.142/~ahkok/git/netdev-2.6 e1000-7.0.38-k2-fixes

these patches are against
 netdev-2.6#upstream 8fc65162a8f25929be80c8d6321a3479e92b5aae


Cheers,

Auke


---
 drivers/net/e1000/e1000_main.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)


--
Auke Kok <auke-jan.h.kok@intel.com>
Intel Pro Ethernet Driver Group
LAN Access Division / Digital Enterprise Group 
