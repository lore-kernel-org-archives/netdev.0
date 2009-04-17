From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Fri, 17 Apr 2009 12:42:40 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904171238550.20049@qirst.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: dada1@cosmosbay.com, Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:38129 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761758AbZDQQt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 12:49:56 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 84A7A82C3B3
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 12:59:55 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Wspo13H60khL for <netdev@vger.kernel.org>;
	Fri, 17 Apr 2009 12:59:55 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 5013482C3B7
	for <netdev@vger.kernel.org>; Fri, 17 Apr 2009 12:59:49 -0400 (EDT)
In-Reply-To: <20090416.160002.09845606.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Apr 2009, David Miller wrote:

> We really need to find a good way to fix that IRQ affinity issue.

Here are the results with setting interrupt affinity. We are still loosing
5 usecs from .22 to .30-rc2. We will investigate more in depth time
permitting.

	UDP ping pong 40 bytes

Kernel		Test 1	Test 2	Test 3	Test 4	Avg
2.6.22		83.1125	83.4	83.03	82.95	83.07
2.6.23		83.33	83.51	83.18	83.42	83.21
2.6.24		82.7775	82.8	82.77	82.77	82.77
2.6.25		85.875	85.94	85.75	86.06	85.75
2.6.26		87.4025	87.53	87.25	87.3	87.53
2.6.27		87.81	87.81	87.77	87.82	87.84
2.6.28		87.4275	87.77	87.24	87.28	87.42
2.6.29		88.4325	88.48	88.42	88.44	88.39
2.6.30-rc2	88.4925	88.49	88.44	88.56	88.48
