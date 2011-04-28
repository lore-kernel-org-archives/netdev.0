From: Ajit <ajitsa_bes@yahoo.com>
Subject: Re: Maximum no of bytes Ethernet can transfer at a time ??
Date: Thu, 28 Apr 2011 06:36:24 +0000 (UTC)
Message-ID: <loom.20110428T083015-693@post.gmane.org>
References: <loom.20110427T140651-957@post.gmane.org> <1303906910.3166.50.camel@edumazet-laptop> <loom.20110427T142551-736@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:60138 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753975Ab1D1Ggm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2011 02:36:42 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QFKq7-0003yf-RH
	for netdev@vger.kernel.org; Thu, 28 Apr 2011 08:36:40 +0200
Received: from 241.snat-111-91-96.hns.net.in ([111.91.96.241])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 08:36:39 +0200
Received: from ajitsa_bes by 241.snat-111-91-96.hns.net.in with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2011 08:36:39 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ajit <ajitsa_bes <at> yahoo.com> writes:

> 
> Eric Dumazet <eric.dumazet <at> gmail.com> writes:
> 
> > Sure, check your syscall returns values, and search for SO_RCVBUF &
> > SO_SNDBUF   (man 7 socket)
> > 
> > --
> 
> okies..I dont know exactly how to use those but I will google and try it..
> will post my result after some time.
> 
> Thank you
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo <at> vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 


hi sir,
I tried out something as you said.

I introduces this lines in my code,

getsockopt(s,SOL_SOCKET,SO_RCVBUF,&optval,&optlen);
printf("The value of optlen is %d\n",optlen);

It always displays 4.

I really have no idea about it. Do I need to use setsockopt options in my
receiver code ??
If so, what difference will it make ??

