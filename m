From: amit.salecha@qlogic.com
Subject: [PATCH NEXT 0/8]qlcnic: driver update
Date: Tue, 22 Jun 2010 06:18:57 -0700
Message-ID: <1277212745-26857-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58522 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754905Ab0FVNTH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jun 2010 09:19:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi
  Major changes:
  1) Previously device context were created in probe and released in remove.
     Now create during interface up and release in interface down.
  2) Dont deallocate and allocate host memory during device reset.
  3) Offload tx timeout recovery to fw recovery functions. Later will
     check fw health before doing tx timeout recovery.

  Series of 8 patches. Please apply them on net-next branch.

-Amit
