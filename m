From: David Dillow <dillowda@ornl.gov>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 19:08:45 -0400
Message-ID: <1210374525.21330.6.camel@lap75545.ornl.gov>
References: <86802c440805071130m62c1f4edydb3316dac4a2aba2@mail.gmail.com>
 <20080507.141521.193714938.davem@davemloft.net> <482498D5.9060008@krogh.cc>
 <20080509.143229.174354251.davem@davemloft.net> <4824C936.9000103@krogh.cc>
 <4824CE43.8060203@hp.com> <4824D4C0.10201@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>,
	David Miller <davem@davemloft.net>, yhlu.kernel@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Jesper Krogh <jesper@krogh.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emroute3.ornl.gov ([160.91.4.110]:39830 "EHLO emroute3.ornl.gov"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756723AbYEJAAN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 May 2008 20:00:13 -0400
In-reply-to: <4824D4C0.10201@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2008-05-10 at 00:48 +0200, Jesper Krogh wrote:
> Rick Jones wrote:
> >> The number of contextswitches seems enourmous.. over 120.000 sometimes.
> >> When transmitting around the same amount of data (4xgigabit bonded with
> >> 802.3ad) 4x110MB/s the amount of contextswitches only reaches 3-4.000. I
> >> have no idea if this has any relevance.
> >>
> >> Should this setup not be able to fill the pipe?
> > 
> > Into which slot was the Neptune inserted?  (sure will be nice to have 
> > Alex Chiang's pci slot id patch in mainline one of these days :)
> > 
> > Is that slot x4, x8, x16?
> 
> I can find out excactly .. on monday. But shouldn't x4 be enough anyway?
> wikipedia says 250MB/s pr. lane. And no slots is less than x4, so I
> thought that it didn't matter to me.

lspci -vvv on the slot can tell you what has been negotiated. Also, you
can figure the effective PCIe bandwidth using ~200 MB/s as a rule of
thumb, given the various overheads on the bus. So an x4 won't fully load
up a 10Gbps link.

At least, that's what we're seeing in x8 slots using Infiniband cards,
so your mileage may vary.
-- 
Dave Dillow
National Center for Computational Science
Oak Ridge National Laboratory
(865) 241-6602 office


