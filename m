From: David Miller <davem@davemloft.net>
Subject: Re: [RFC-PATCH] netfilter: payload_len is be16, add size of struct
 rather than size of pointer
Date: Mon, 10 Nov 2008 16:46:17 -0800 (PST)
Message-ID: <20081110.164617.84739529.davem@davemloft.net>
References: <1226078023.11596.17.camel@brick>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wensong@linuxvirtualserver.org, ja@ssi.bg, netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45385
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751771AbYKKAqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 19:46:17 -0500
In-Reply-To: <1226078023.11596.17.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Fri, 07 Nov 2008 09:13:43 -0800

> payload_len is a be16 value, not cpu_endian, also the size of a ponter
> to a struct ipv6hdr was being added, not the size of the struct itself.
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied, thanks for fixing this Harvey.
