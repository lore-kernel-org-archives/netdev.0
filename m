From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH NEXT 2/2] qlcnic: Qlogic ethernet driver for CNA devices
Date: Tue, 5 Jan 2010 09:12:16 -0800
Message-ID: <20100105091216.09cf4d17@nehalam>
References: <1262697876-26206-1-git-send-email-amit.salecha@qlogic.com>
	<1262697876-26206-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	dhananjay.phadke@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:40096 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755136Ab0AERM1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jan 2010 12:12:27 -0500
In-Reply-To: <1262697876-26206-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

One valid complaint from checkpatch:

ERROR: Macros with complex values should be enclosed in parenthesis
#2096: FILE: drivers/net/qlcnic/qlcnic_ethtool.c:41:
+#define QLCNIC_STAT(m) sizeof(((struct qlcnic_adapter *)0)->m), \
+			offsetof(struct qlcnic_adapter, m)

total: 1 errors, 0 warnings, 9611 lines checked
