From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Re: BUG: IPv6 stops working after a while, needs ip ne del
 command to reset
Date: Tue, 17 Aug 2010 11:31:12 -0700
Message-ID: <20100817183112.GA4351@mcarlson.broadcom.com>
References: <alpine.DEB.1.10.1008161224510.13728@red.crap.retrofitta.se>
 <alpine.DEB.1.10.1008170719180.21857@red.crap.retrofitta.se>
 <1282024802.2487.687.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171053230.21857@red.crap.retrofitta.se>
 <1282050920.2448.47.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171547090.21857@red.crap.retrofitta.se>
 <1282055659.2448.58.camel@edumazet-laptop>
 <alpine.DEB.1.10.1008171737260.21857@red.crap.retrofitta.se>
 <20100817171115.GA4134@mcarlson.broadcom.com>
 <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Matthew Carlson" <mcarlson@broadcom.com>,
	"Eric Dumazet" <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Thomas Habets" <thomas@habets.pp.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2072 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933241Ab0HQSbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Aug 2010 14:31:23 -0400
In-Reply-To: <alpine.DEB.1.10.1008171928160.21857@red.crap.retrofitta.se>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 17, 2010 at 10:29:54AM -0700, Thomas Habets wrote:
> On Tue, 17 Aug 2010, Matt Carlson wrote:
> >>> But if problem remains even with "ifconfig eth0 allmulti" I suspect a
> >>> NIC firmware problem. (allmulti set to 1 all the 128 bits of filters)
> > Thomas, can you give me the output of 'ethtool -i eth0'?
> 
> $ sudo ethtool -i eth0
> driver: tg3
> version: 3.110
> firmware-version: 5715-v3.28, UMP 1.15
> bus-info: 0000:03:04.0

Thanks.  I put the question out to the firmware developer.  While we
wait, can you keep Eric's patch in place and give me the results along
with the output of 'ethtool -d eth0 | grep 0x047' after the problem
happens?

Eric's patch shows the hash registers at the time they are programmed.
I'm interested to see if the values change (by firmware) after the
failure.

