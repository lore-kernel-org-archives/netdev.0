From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 15 Jan 2007 22:33:36 +0300
Message-ID: <45ABD710.5070105@tls.msk.ru>
References: <E1H6OJU-0001EC-00@gondolin.me.apana.org.au> <45AB82F1.9000409@tls.msk.ru> <45ABC43F.7090202@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.94.6]:20522 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751425AbXAOTdl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jan 2007 14:33:41 -0500
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <45ABC43F.7090202@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Michael Tokarev a e'crit :
>>
>> Any idea how to force sending FIN-with-data?
> 
> int flag_on = 1;
> setsockopt(fd, SOL_TCP, TCP_CORK, &flag_on, sizeof(int));
> send(fd, data, datalen, 0);
> close(fd);

That produces two packets - one (or more - depending on the
size) data packet and one FIN packet w/o any data.

This is the first thing I've tried.

/mjt
