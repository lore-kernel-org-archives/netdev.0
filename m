From: "Martin Schiller" <mschiller@tdt.de>
Subject: RE: Suppress / delay SYN-ACK
Date: Mon, 16 Oct 2006 08:52:06 +0200
Message-ID: <004001c6f0ef$97e82020$1a04010a@V505CP>
References: <452FF379.2080600@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:48855 "EHLO ns.tdt.de")
	by vger.kernel.org with ESMTP id S1751480AbWJPGwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 02:52:00 -0400
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id k9G6pwC08614
	for <netdev@vger.kernel.org>; Mon, 16 Oct 2006 08:51:58 +0200
To: "'Eric Dumazet'" <dada1@cosmosbay.com>
In-Reply-To: <452FF379.2080600@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, October 13, 2006 10:14 PM, Eric Dumazet wrote:
>
> Martin, I played with libnetfilter_queue
> (http://www.netfilter.org/projects/libnetfilter_queue/index.html)
> 
> With this single iptables rules, I was able to do what you want :
> transmit the SYN message to a user application, that may DROP this
> packet or let it pass normal TCP stack.  
> 
> iptables -A INPUT -p tcp --dport 333 --syn -j QUEUE
> 
> Then hack nfqnl_test.c to meet your needs (see nfq_set_verdict(),
> nfq_get_payload())
> 
> Be prepared to receive the 'same SYN' several time if your X.25 call
> attempt is too long. 
> 
> (You have to be root unfortunatly)
> 
> Eric

Thanks, this sounds very interesting. I will have a closer look at that.

Martin


