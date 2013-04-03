From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Bug#565404: linux-image-2.6.26-2-amd64: atl1e: TSO is broken
Date: Wed, 3 Apr 2013 02:43:58 +0200
Message-ID: <20130403004358.GB20292@order.stressinduktion.org>
References: <1364689558.3557.22.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F202477@nasanexd02f.na.qualcomm.com> <1364695805.3557.41.camel@deadeye.wl.decadent.org.uk> <157393863283F442885425D2C45428564F20261B@nasanexd02f.na.qualcomm.com> <20130402211524.GE4924@order.stressinduktion.org> <157393863283F442885425D2C45428564F202AD5@nasanexd02f.na.qualcomm.com> <20130402221913.GG4924@order.stressinduktion.org> <157393863283F442885425D2C45428564F202B2A@nasanexd02f.na.qualcomm.com> <20130403000020.GI4924@order.stressinduktion.org> <157393863283F442885425D2C45428564F202BB6@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Anders =?utf-8?Q?Bostr=C3=B6m?= <anders@netinsight.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"565404@bugs.debian.org" <565404@bugs.debian.org>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47532 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758265Ab3DCAoA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 20:44:00 -0400
Content-Disposition: inline
In-Reply-To: <157393863283F442885425D2C45428564F202BB6@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 03, 2013 at 12:12:12AM +0000, Huang, Xiong wrote:
> > > Hannes,  Thanks for your testing !
> > >
> > >  simply revising MAX_TX_BUF_LEN to 0x4000 will cause incorrect TX
> > configuration...
> > > I mean you can try to put a gso size limit of 0x4000 (or 0x5000)....
> > 
> > I tested both values with multi-gigabyte nfsv4 traffic and both values are ok.
> > If I understand you correctly 0x4000 is a safe limit?
> 
> Since Win7 driver uses 15000 bytes as its max packet length for TSO, I think 0x3C00 is more safer than 0x4000. :)

Thanks again for helping to resolve this issue. I just submitted a patch
but accidently killed the cc-line.

Greetings,

  Hannes
