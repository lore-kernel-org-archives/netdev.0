From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 13:15:00 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0810311313060.7072@wrl-59.cs.helsinki.fi>
References: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi>
 <20081031.005219.141937694.davem@davemloft.net>
 <Pine.LNX.4.64.0810311119510.7072@wrl-59.cs.helsinki.fi>
 <20081031.025159.51432990.davem@davemloft.net> <490AE1CD.9040207@cosmosbay.com>
 <Pine.LNX.4.64.0810311300130.7072@wrl-59.cs.helsinki.fi> <490AE792.60200@cosmosbay.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1642721910-1225451700=:7072"
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	zbr@ioremap.net, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, efault@gmx.de,
	Andrew Morton <akpm@linux-foundation.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33556 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbYJaLPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 07:15:09 -0400
In-Reply-To: <490AE792.60200@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1642721910-1225451700=:7072
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Fri, 31 Oct 2008, Eric Dumazet wrote:

> Ilpo Järvinen a écrit :
> > On Fri, 31 Oct 2008, Eric Dumazet wrote:
> > 
> > > David Miller a écrit :
> > > > From: "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi>
> > > > Date: Fri, 31 Oct 2008 11:40:16 +0200 (EET)
> > > > > > Let me remind that it is just a single process, so no ping-pong 
> >> & other
> > > > > lock related cache effects should play any significant role here, 
> > > no? (I'm
> > > > > no expert though :-)).
> > > > > Not locks or ping-pongs perhaps, I guess.  So it just sends and
> > > > receives over a socket, implementing both ends of the communication
> > > > in the same process?
> > > > > If hash chain conflicts do happen for those 2 sockets, just 
> > > traversing
> > > > the chain 2 entries deep could show up.
> > >
> > > tbench is very sensible to cache line ping-pongs (on SMP machines of
> > > course)
> > 
> > ...Sorry to disappoint you but we were discussion there on my AIM9 tcp_test
> > results :-).
> > 
> 
> Well, before you added AIM9 on this topic, we were focusing on tbench :)
>
> Sorry to disappoint you :)

It's all Stephen's fault, he added port randomization first... ;-)

-- 
 i.
---696208474-1642721910-1225451700=:7072--
