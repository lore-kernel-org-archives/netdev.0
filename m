From: "Martin Schiller" <mschiller@tdt.de>
Subject: RE: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 12:13:26 +0200
Message-ID: <000201c6ede7$0ef3e110$1a04010a@V505CP>
References: <200610121038.18309.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:25001 "EHLO ns.tdt.de")
	by vger.kernel.org with ESMTP id S965067AbWJLKNZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 06:13:25 -0400
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id k9CADNt05958
	for <netdev@vger.kernel.org>; Thu, 12 Oct 2006 12:13:23 +0200
To: "'Eric Dumazet'" <dada1@cosmosbay.com>
In-Reply-To: <200610121038.18309.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, October 12, 2006 10:38 AM, Eric Dumazet wrote:
>
> Well, it is already possible to delay the 'third packet' of an
> outgoing connection with a litle hack. But AFAIK not the SYNACK of
> incoming connection. It could be cool. Maybe some new syscalls are
> needed:   
> 
> int syn_recv(int socklisten, ...);
> /* give to user app the SYN packet */
> int syn_ack(int socklisten, ...);
> /* User app has the ability to ask kernel tcp stack to :
>     DROP this packet.
>     REJECT the attempt
>     ACCEPT the attempt (sending a SYN/ACK) */
> 

So, when do you mean the user-space application should run this syscalls?
After the call to listen()?

Another problem with this solution might be, that I don't want to block the
listening socket with the processing of one request, because there could be
a lot of simultaneous requests. 


