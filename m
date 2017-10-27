From: Kirill Smelkov <kirr@nexedi.com>
Subject: Re: [PATCH] r8169: Add support for interrupt coalesce tuning
 (ethtool -C)
Date: Fri, 27 Oct 2017 15:54:14 +0300
Message-ID: <20171027125414.fs27hokqmlnrsse7@deco.navytux.spb.ru>
References: <20171027102449.19756-1-kirr@nexedi.com>
 <17a1d528-5127-e01d-d982-87be3b09cba5@applied-asynchrony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        Francois Romieu <romieu@fr.zoreil.com>,
        Hayes Wang <hayeswang@realtek.com>,
        Realtek linux nic maintainers <nic_swsd@realtek.com>,
        David Laight <David.Laight@ACULAB.COM>,
        =?iso-8859-1?Q?St=E9phane?= ANCELOT <sancelot@free.fr>,
        Eric Dumazet <edumazet@google.com>
To: Holger =?iso-8859-1?Q?Hoffst=E4tte?=
        <holger@applied-asynchrony.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.tiolive.com ([94.23.229.207]:39938 "EHLO
        mail2.tiolive.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752228AbdJ0MyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 08:54:17 -0400
Content-Disposition: inline
In-Reply-To: <17a1d528-5127-e01d-d982-87be3b09cba5@applied-asynchrony.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 27, 2017 at 02:43:02PM +0200, Holger Hoffstätte wrote:
> On 10/27/17 12:24, Kirill Smelkov wrote:
> > 
> > Kirr: In particular with
> > 
> > 	ethtool -C <ifname> rx-usecs 0 rx-frames 0
> > 
> > now it is possible to disable RX delays when NIC usage requires low-latency.
> > 
> > See this thread for context:
> > 
> > 	https://www.spinics.net/lists/netdev/msg217665.html
> 
> (snip)
> 
> > We have this patch running in our testing setup for 1 months already
> > without any issues observed.
> 
> Same here, running on NFS/mail/web server & development workstation without
> issues. I was really dismayed to see the IMHO unreasonably high coalescing
> defaults.
> 
> > I've got no feedback at all to my original posting of this patch and questions
> > 
> > 	https://www.spinics.net/lists/netdev/msg457173.html
> > 
> > neither from Francois, nor from any people from Realtek during one month.
> 
> I thought I had already replied to your previous mail, but apparently had
> not..sorry. :/
> 
> Tested-by: Holger Hoffstätte <holger@applied-asynchrony.com>

Holger, thanks for feedback.

Kirill


> > So I suggest we simply apply it to net-next.git now.
> 
> cheers!
> 
> Holger
