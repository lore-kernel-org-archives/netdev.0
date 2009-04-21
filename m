From: Christoph Lameter <cl@linux.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Tue, 21 Apr 2009 10:00:15 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0904210959510.19969@qirst.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com>
 <alpine.DEB.1.10.0904201305360.1585@qirst.com> <49ECB775.6030202@cosmosbay.com> <alpine.DEB.1.10.0904201410430.3361@qirst.com> <49ECC30A.9040501@cosmosbay.com> <alpine.DEB.1.10.0904201510410.17816@qirst.com> <49ECD5E4.60100@cosmosbay.com>
 <alpine.DEB.1.10.0904201712140.27942@qirst.com> <49ECEE9E.7050307@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ultrahosting.com ([74.213.174.254]:42260 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbZDUOIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2009 10:08:35 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id BC36182C6E6
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 10:18:53 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id naPX64AKgUBt for <netdev@vger.kernel.org>;
	Tue, 21 Apr 2009 10:18:47 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 9437C82C6E5
	for <netdev@vger.kernel.org>; Tue, 21 Apr 2009 10:18:35 -0400 (EDT)
In-Reply-To: <49ECEE9E.7050307@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Apr 2009, Eric Dumazet wrote:

> Not on 32bits afaik, with glibc I use at least, strace told me.

Right the vsyscall optimizations are not for 32 bit.
