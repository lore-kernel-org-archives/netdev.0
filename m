From: "Angelo P. Castellani" <angelo.castellani@gmail.com>
Subject: [PATCH 1/2][TCP] YeAH-TCP: algorithm implementation
Date: Mon, 19 Feb 2007 11:46:02 +0100
Message-ID: <45D97FEA.1080006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrea Baiocchi <andrea.baiocchi@uniroma1.it>,
	Francesco Vacirca <francesco@net.infocom.uniroma1.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:42953 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbXBSKqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 05:46:07 -0500
Received: by nf-out-0910.google.com with SMTP id o25so2387586nfa
        for <netdev@vger.kernel.org>; Mon, 19 Feb 2007 02:46:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Angelo P. Castellani <angelo.castellani@gmail.con>

YeAH-TCP is a sender-side high-speed enabled TCP congestion control
algorithm, which uses a mixed loss/delay approach to compute the
congestion window. It's design goals target high efficiency, internal,
RTT and Reno fairness, resilience to link loss while keeping network
elements load as low as possible.

For further details look here:
    http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf

Signed-off-by: Angelo P. Castellani <angelo.castellani@gmail.con>

---

This is the YeAH-TCP implementation of the algorithm presented to
PFLDnet2007 (http://wil.cs.caltech.edu/pfldnet2007/).

Regards,
Angelo P. Castellani

 Kconfig    |   14 ++
 Makefile   |    1
 tcp_yeah.c |  288
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 tcp_yeah.h |  134 ++++++++++++++++++++++++++++
 4 files changed, 437 insertions(+)

