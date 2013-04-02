From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Wed, 3 Apr 2013 00:15:20 +0200
Message-ID: <20130402221520.GF4924@order.stressinduktion.org>
References: <CDAFEDABF718A54BABD0DA5476695307475CCD42@SHEXMB-01.global.atheros.com> <20100125.163612.582489483209420341.anders@netinsight.net> <CDAFEDABF718A54BABD0DA5476695307475CCFF8@SHEXMB-01.global.atheros.com> <20100126.093439.651115405791675606.anders@netinsight.net> <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com> <1364695805.3557.41.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F20261B@nasanexd02f.na.qualcomm.com> <20130402211524.GE4924@order.stressinduktion.org> <1364940038.5113.187.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "Huang, Xiong" <xiong@qca.qualcomm.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	Anders =?utf-8?Q?Bostr=C3=B6m?= <anders@netinsight.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47077 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760740Ab3DBWPW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 18:15:22 -0400
Content-Disposition: inline
In-Reply-To: <1364940038.5113.187.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 02, 2013 at 03:00:38PM -0700, Eric Dumazet wrote:
> On Tue, 2013-04-02 at 23:15 +0200, Hannes Frederic Sowa wrote:
> 
> > The error vanishes as soon as I put a gso size limit of MAX_TX_BUF_LEN
> > in the driver. MAX_TX_BUF_LEN seems to be arbitrary set to 0x2000. I
> > can even raise it to 0x3000 and don't see any tcp retransmits. Do you
> > have an advice on how to size this value (e.g. should we switch to the
> > windows values)?
> 
> This looks like an overflow error...

Thanks for your input, Eric.

I am limited in my time to work on this today but nontheless just tested
your patch without any of my changes and count a lot of TcpRetransSegs
again. Either there is really some hardware limitation or another
overflow.
