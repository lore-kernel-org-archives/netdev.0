From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: [PATCH 2/5] Fix TX Pause bug (reset_tx, intr_handler)
Date: Mon, 2 Oct 2006 17:54:16 +0800
Message-ID: <023b01c6e608$b8dc9af0$4964a8c0@icplus.com.tw>
References: <1159813476.2576.2.camel@localhost.localdomain> <20061001235338.566f4a67.akpm@osdl.org>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr50.hinet.net ([168.95.4.150]:61630 "EHLO msr50.hinet.net")
	by vger.kernel.org with ESMTP id S1750898AbWJBJy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 05:54:27 -0400
To: "Andrew Morton" <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When TxUnderrun happen, driver will re-enable tx. But during
this enable process, TxUnderrun maybe happen again. So driver
need to make sure Tx was actually enabled.

----- Original Message ----- 
From: "Andrew Morton" <akpm@osdl.org>
To: "Jesse Huang" <jesse@icplus.com.tw>
Cc: <linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>;
<jgarzik@pobox.com>
Sent: Monday, October 02, 2006 2:53 PM
Subject: Re: [PATCH 2/5] Fix TX Pause bug (reset_tx, intr_handler)


On Mon, 02 Oct 2006 14:24:36 -0400
Jesse Huang <jesse@icplus.com.tw> wrote:

> Fix TX Pause bug (reset_tx, intr_handler)

Please describe this bug more completely.    How does this patch solve it?


