From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] af_packet: do not accept mc address
 smaller then dev->addr_len in packet_mc_add()
Date: Fri, 26 Feb 2010 04:19:48 -0800 (PST)
Message-ID: <20100226.041948.134766793.davem@davemloft.net>
References: <20100225095703.GB2667@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48546
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935932Ab0BZMTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2010 07:19:30 -0500
In-Reply-To: <20100225095703.GB2667@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 25 Feb 2010 10:57:04 +0100

> There is no point of accepting an address of smaller length than dev->addr_len
> here. Therefore change this for stonger check.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
