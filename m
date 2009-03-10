From: Marian =?utf-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Tue, 10 Mar 2009 17:00:40 +0100
Message-ID: <20090310160040.GA93054@bts.sk>
References: <20090309195906.M50328@bts.sk> <1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com> <20090310104956.GA81181@bts.sk> <20090310.043019.132650585.davem@davemloft.net> <20090310114606.GA84964@bts.sk> <1e41a3230903100823h5d5768d9wb9f36eb294840814@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from saus.bts.sk ([194.160.23.4]:55484 "EHLO saus.bts.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753932AbZCJQAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 12:00:43 -0400
Content-Disposition: inline
In-Reply-To: <1e41a3230903100823h5d5768d9wb9f36eb294840814@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Yes, but that's actual bandwidth between sender and receiver, not
> > the hard BW limit of the receiver's NIC. My intention is just to introduce
> > some safety belt preventing autotuning to increase the rx window
> > into MB ranges when RTT is very low.
> 
> Nowhere in our proposal do you use NIC bandwidth.  What you proposed
> can be done easily at the sender.

Only if you *absolutely* trust the sender to do everything correctly.
That's never the case on global scale - some senders are buggy, some teribly
outdated, some incorrectly configured, some using different congestion
control scheme...

Again, autotuning in its present form removes all safety at the receiver
side and allows senders to easily bring LANs down. IMHO we need to fix
this before the problem spreads even more.

   Thanks & kind regards,

         M.
