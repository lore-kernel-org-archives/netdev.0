From: "Martin Schiller" <mschiller@tdt.de>
Subject: RE: Suppress / delay SYN-ACK
Date: Tue, 17 Oct 2006 14:04:04 +0200
Message-ID: <001501c6f1e4$5a23f020$1a04010a@V505CP>
References: <20061016070212.GB22667@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.tdt.de ([195.243.126.82]:58249 "EHLO ns.tdt.de")
	by vger.kernel.org with ESMTP id S1750698AbWJQMEI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 08:04:08 -0400
Received: from ns (root@localhost)
	by ns.tdt.de (8.11.6/8.11.6/SuSE Linux 0.5) with SMTP id k9HC41q01629
	for <netdev@vger.kernel.org>; Tue, 17 Oct 2006 14:04:01 +0200
To: "'Lennert Buytenhek'" <buytenh@wantstofly.org>
In-Reply-To: <20061016070212.GB22667@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, October 16, 2006 9:02 AM, Lennert Buytenhek wrote:
> 
> I wrote something like this a couple of years ago:
> 
> 	http://marc.theaimsgroup.com/?l=linux-netdev&m=103666165629419&w=2
> 	http://marc.theaimsgroup.com/?l=linux-netdev&m=106089519611631&w=2
> 
> There wasn't a whole lot of external interest, and my need for it
> disappeared, so I never really finished it, and there's a couple of
> unfixed bugs,  
> 

Lennert's patch does nearly exactly the way how I tried to do it earlier by
myself and after porting the patch to kernel 2.6.15.4 and 2.6.11.12, which I
am currently using, it works great.

The only change I've made is that I don't want to send the SYN-ACK only with
the first write() on the socket, because in my application the requesting
client is also the one who starts sending data. So I introduced an ioctl()
which simply runs tcp_confirm() to send the SYN-ACK.

So...
Thanks a lot to everyone who gave me hints and tips to solve my problem.

Martin


