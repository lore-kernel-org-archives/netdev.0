From: Bastian Stender <bst@pengutronix.de>
Subject: [PATCH v2] net ipv4: use preferred log methods
Date: Fri, 13 Nov 2015 11:40:33 +0100
Message-ID: <1447411234-2067-1-git-send-email-bst@pengutronix.de>
References: <1443625231-1871-1-git-send-email-bst@pengutronix.de>
Cc: netdev@vger.kernel.org, trivial@kernel.org, kernel@pengutronix.de,
	Bastian Stender <bst@pengutronix.de>
To: "David S . Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:47142 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932849AbbKMKlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 05:41:36 -0500
In-Reply-To: <1443625231-1871-1-git-send-email-bst@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace printk calls with preferred unconditional log method calls to keep
kernel messages clean. Conditional printks were left untouched to avoid
change in behaviour.

Furthermore a newline was added to the "too small MTU" message.
