From: Marc Donner <donner@dbd-breitband.de>
Subject: Re: TCP_MD5 and Intel e1000
Date: Tue, 22 May 2007 12:33:25 +0200
Message-ID: <200705221233.25858.donner@dbd-breitband.de>
References: <C2786969.24B46%webmaster@poweraudio.de> <20070522.183647.75785266.yoshfuji@linux-ipv6.org> <20070522.031432.08079709.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	webmaster@poweraudio.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.dbd-breitband.de ([217.188.211.21]:33963 "EHLO
	dbd-mpx01.dbd-breitband.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754788AbXEVK43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2007 06:56:29 -0400
In-Reply-To: <20070522.031432.08079709.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 22 May 2007, David Miller wrote:
> From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
> Date: Tue, 22 May 2007 18:36:47 +0900 (JST)
>
> > In article <20070522105738.f03cb83b.dada1@cosmosbay.com> (at Tue, 22 May 
2007 10:57:38 +0200), Eric Dumazet <dada1@cosmosbay.com> says:
> > > > I have tried to set up quagga with tcp-md5 support from kernel. All
> > > > seems ok with a intel e100 NIC, but as i testetd with a intel e1000
> > > > NIC the tcp packets have an invalid md5 digest.
> > > > If i run tcpdump on the mashine the packets are generated, it shows
> > > > on the outgoing interface invalid md5 digests.
> > > > Are there known issues about tcp-md5 and e1000 NICs?
> > >
> > > You could try "ethtool -K tx off", and/or other ethtool -K settings
> >
> > Disabling offloading should help; currently tcp-md5 stack
> > blindly copy md5-signature from the first segment
> > which is not appropriate for rest of segments.
>
> It is clear we should disable TSO for sockets making use of TCP-MD5.

disabling tso works. thanks
