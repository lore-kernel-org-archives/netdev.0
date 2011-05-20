From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: RE: packet received in a wrong rx-queue?
Date: Thu, 19 May 2011 18:48:02 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D8853B7@MILEXCH2.ds.jdsu.net>
References: <4A6A2125329CFD4D8CC40C9E8ABCAB9F250D749114@MILEXCH2.ds.jdsu.net>
	<20110518.213225.1546509125052154115.davem@davemloft.net>
	<4A6A2125329CFD4D8CC40C9E8ABCAB9F250D7491A8@MILEXCH2.ds.jdsu.net>
 <20110518.233614.1134947771941589398.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og113.obsmtp.com ([64.18.2.179]:47449 "HELO
	exprod7og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S934742Ab1ETBwT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 21:52:19 -0400
In-Reply-To: <20110518.233614.1134947771941589398.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, May 19, 2011 11:36 AM
> To: Jon Zhou
> Cc: e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org
> Subject: Re: packet received in a wrong rx-queue?
> 
> From: Jon Zhou <Jon.Zhou@jdsu.com>
> Date: Wed, 18 May 2011 20:22:07 -0700
> 
> > form the 82599 datasheet, the hash algorithm is consist of src/dst
> > ip, src/dst port,protocol why it got different hash value with same
> > ip/port pair?
> 
> The same reason why feeding different sets of discrete 32-bit and
> 16-bit values to a cryptographic hash results in a different final
> hash value.
> 
> Our software RPS/RFS implementation used to have this quality too.

Even that it gets different hash value, both packets should be delivered to same rx-queue,

Because they are belong to same flow?

