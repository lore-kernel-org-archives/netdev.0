From: David Miller <davem@davemloft.net>
Subject: Re: NIU - Sun Neptune 10g - Transmit timed out reset (2.6.24)
Date: Fri, 09 May 2008 15:07:56 -0700 (PDT)
Message-ID: <20080509.150756.157662019.davem@davemloft.net>
References: <482498D5.9060008@krogh.cc>
	<20080509.143229.174354251.davem@davemloft.net>
	<4824C936.9000103@krogh.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yhlu.kernel@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: jesper@krogh.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47138
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751079AbYEIWIC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:08:02 -0400
In-Reply-To: <4824C936.9000103@krogh.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Krogh <jesper@krogh.cc>
Date: Fri, 09 May 2008 23:59:18 +0200

> David Miller wrote:
> > From: Jesper Krogh <jesper@krogh.cc>
> > Date: Fri, 09 May 2008 20:32:53 +0200
> > 
> >> When it works I doesnt seem to be able to get it pass 500MB/s.
> > 
> > With this card you really need multiple cpus and multiple threads
> > sending data through the card in order to fill the 10Gb pipe.
> > 
> > Single connections will not fill the pipe.
> 
> The server is a Sun X4600 with 8 x dual-core CPU's, setup with 64
> NFS-threads. The other end of the fiber goes into a switch with gigabit
> ports connected to 48 dual-core cpus. The test was done doing a dd on a
> 4.5GB file from the server to /dev/null on the clients.

A single file transfer will not fill the pipe using this card, no
matter how many cpus you have :-)

The card is designed such that multiple parallel data streams over
different connections result in the greatest throughput.

> Should this setup not be able to fill the pipe?

Nope, not with this card.
