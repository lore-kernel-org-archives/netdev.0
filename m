From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 15 Jan 2007 19:13:19 +0100
Message-ID: <45ABC43F.7090202@cosmosbay.com>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58857 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751146AbXAOSau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jan 2007 13:30:50 -0500
To: Michael Tokarev <mjt@tls.msk.ru>
In-Reply-To: <45AB82F1.9000409@tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Tokarev a e'crit :
> 
> Any idea how to force sending FIN-with-data?

int flag_on = 1;
setsockopt(fd, SOL_TCP, TCP_CORK, &flag_on, sizeof(int));
send(fd, data, datalen, 0);
close(fd);


Eric Dumazet
