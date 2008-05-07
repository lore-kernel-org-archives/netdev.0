From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Wed, 07 May 2008 14:15:21 -0700 (PDT)
Message-ID: <20080507.141521.193714938.davem@davemloft.net>
References: <4821F3B7.2090702@krogh.cc>
	<86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jesper@krogh.cc, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: yhlu.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42662
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbYEGVP1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 17:15:27 -0400
In-Reply-To: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Date: Wed, 7 May 2008 11:30:18 -0700

> On Wed, May 7, 2008 at 11:23 AM, Jesper Krogh <jesper@krogh.cc> wrote:
> > Hi.
> >
> >  I get errors like this after a few minutes of traffic on a Sun Neptune 10g
> > ethernet card. (with nice 500MB/s throughput).
> >
> >  Then the server seems too busy with something, so it doesn't even respont
> > to a serial terminal login.
> >
> >  May  7 16:16:33 hest kernel: [  166.948958] niu: niu_get_parent:
> > platform_type[1] port[3]
> >  May  7 16:16:33 hest kernel: [  166.949366] niu: niu_get_and_validate_port:
> > port[3] num_ports[2]
> >  May  7 16:16:33 hest kernel: [  166.949886] niu: niu_put_parent: port[3]
> >  .. bootup ends here ..
> >  May  7 17:13:54 hest kernel: [ 3670.128178] niu 0000:84:00.0: niu: eth4:
> > Transmit timed out, resetting
> >  May  7 17:14:04 hest kernel: [ 3680.108614] niu 0000:84:00.0: niu: eth4:
> > Transmit timed out, resetting
> >  May  7 17:14:14 hest kernel: [ 3690.093089] niu 0000:84:00.0: niu: eth4:
> > Transmit timed out, resetting
> >  May  7 17:14:19 hest kernel: [ 3695.079254] niu 0000:84:00.0: niu: eth4:
> > Transmit timed out, resetting
> >  May  7 17:14:24 hest kernel: [ 3700.073525] niu 0000:84:00.0: niu: eth4:
> > Transmit timed out, resetting
> >  May  7 17:14:29 hest kernel: [ 3705.063744] niu 0000:84:00.0: niu: eth4:
> > Transmit timed out, resetting
> >  May  7 17:14:34 hest kernel: [ 3710.049918] niu 0000:84:00.0: niu: eth4:
> > Transmit timed out, resetting
> >
> >
> >  Any suggestions?
> >
> >  The system is an Ubuntu Hardy (2.6.24-17-server) amd64.
> 
> can you try 2.6.25 or current git?

Also, please always CC: netdev@vger.kernel.org on networking reports.

Thank you.
