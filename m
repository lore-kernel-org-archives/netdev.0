From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net 1/4] bnx2x: Fix link for KR with swapped polarity
 lane
Date: Wed, 11 Jun 2014 18:40:35 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63AE83CA@avmb3.qlogic.org>
References: <1402493248-5427-1-git-send-email-yuval.mintz@qlogic.com>
 <1402493248-5427-2-git-send-email-yuval.mintz@qlogic.com>,<53985B45.9020604@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev <netdev@vger.kernel.org>,
	Yaniv Rosner <Yaniv.Rosner@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:45858 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753806AbaFKSkk convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 14:40:40 -0400
In-Reply-To: <53985B45.9020604@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> +                             MDIO_WC_REG_RX0_PCI_CTRL + (0x10 * lane), &val);

>    () around * not needed. You could also replace it by (lane << 4).

Hi,

bnx2x_link.c is full of format inconsistencies, as well as many cases of
unnecessary parenthesis.
It might be reasonable to send a semantic script to `net-next' in order
to fix all those issues, but I'm not sure we should re-spin this series
only because of such `common' inconsistencies.

Dave - whichever you prefer; If you want me to re-spin it, I will.

Cheers,
Yuval

________________________________

This message and any attached documents contain information from QLogic Corporation or its wholly-owned subsidiaries that may be confidential. If you are not the intended recipient, you may not read, copy, distribute, or use this information. If you have received this transmission in error, please notify the sender immediately by reply e-mail and then delete this message.
