From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Tue, 17 Oct 2006 14:54:19 +0200
Message-ID: <200610171454.20193.dada1@cosmosbay.com>
References: <001501c6f1e4$5a23f020$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "'Lennert Buytenhek'" <buytenh@wantstofly.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:722 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1750843AbWJQMyV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 08:54:21 -0400
To: "Martin Schiller" <mschiller@tdt.de>
In-Reply-To: <001501c6f1e4$5a23f020$1a04010a@V505CP>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 17 October 2006 14:04, Martin Schiller wrote:
> On Monday, October 16, 2006 9:02 AM, Lennert Buytenhek wrote:
> > I wrote something like this a couple of years ago:
> >
> > 	http://marc.theaimsgroup.com/?l=linux-netdev&m=103666165629419&w=2
> > 	http://marc.theaimsgroup.com/?l=linux-netdev&m=106089519611631&w=2
> >
> > There wasn't a whole lot of external interest, and my need for it
> > disappeared, so I never really finished it, and there's a couple of
> > unfixed bugs,
>
> Lennert's patch does nearly exactly the way how I tried to do it earlier by
> myself and after porting the patch to kernel 2.6.15.4 and 2.6.11.12, which
> I am currently using, it works great.
>
> The only change I've made is that I don't want to send the SYN-ACK only
> with the first write() on the socket, because in my application the
> requesting client is also the one who starts sending data. So I introduced
> an ioctl() which simply runs tcp_confirm() to send the SYN-ACK.


Well, did you solve Lennert problem if the final (third packet of three packet 
TCP establishment handshake) packet is missing ?
It seems no timer will fire and tell you the socket is not usable...

Eric
