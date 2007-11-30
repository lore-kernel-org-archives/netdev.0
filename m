From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/3] [SNMP]: Defer InDataGrams increment until recvmsg() does checksum
Date: Fri, 30 Nov 2007 10:57:44 +0000
Message-ID: <20071130105744.GD27512@gerrit.erg.abdn.ac.uk>
References: <474F7EE8.2040009@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	andi@firstfloor.org, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55825 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757726AbXK3K6x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Nov 2007 05:58:53 -0500
Content-Disposition: inline
In-Reply-To: <474F7EE8.2040009@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks again for all the work.
| UdpInDatagrams can be confusing because it counts packets that 
| might be dropped later.
| Move UdpInDatagrams into recvmsg() as allowed by the RFC.
| 
| Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
| ---
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
