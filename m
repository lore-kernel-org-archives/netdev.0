From: Ron Mercer <ron.mercer@qlogic.com>
Subject: Re: [PATCH] qlge: Fix incorrect usage of module parameters and
	netdev msg level
Date: Thu, 18 Nov 2010 14:17:14 -0800
Message-ID: <20101118221713.GB14333@linux-ox1b.qlogic.org>
References: <20101118215002.GS32203@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Milton Miller <miltonm@bga.com>,
	Linux Driver <Linux-Driver@qlogic.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"sonnyrao@linux.vnet.ibm.com" <sonnyrao@linux.vnet.ibm.com>
To: Sonny Rao <sonnyrao@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cain.qlogic.com ([198.70.193.223]:60708 "EHLO cain.qlc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756730Ab0KRW3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 17:29:38 -0500
Content-Disposition: inline
In-Reply-To: <20101118215002.GS32203@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 18, 2010 at 01:50:02PM -0800, Sonny Rao wrote:
> Driver appears to be mistaking the permission field with default value
> in the case of debug and qlge_irq_type.
> 
> Driver is also passing debug as a bitmask into netif_msg_init()
> which wants a number of bits.  Ron Mercer suggests we should
> change this to pass in -1 so the defaults get used instead,
> which makes the default much less verbose.
> 
> Signed-off-by: Milton Miller <miltonm@bga.com>
> Signed-off-by: Sonny Rao <sonnyrao@linux.vnet.ibm.com>

Milton/Sonny,
Did you happen to test this to see if the log output was the same? 
