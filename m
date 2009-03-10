From: Marian =?utf-8?B?xI51cmtvdmnEjQ==?= <md@bts.sk>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Tue, 10 Mar 2009 12:46:06 +0100
Message-ID: <20090310114606.GA84964@bts.sk>
References: <20090309195906.M50328@bts.sk> <1e41a3230903091323j541d1895j2eb69b9f9c11f2f3@mail.gmail.com> <20090310104956.GA81181@bts.sk> <20090310.043019.132650585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johnwheffner@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from saus.bts.sk ([194.160.23.4]:57120 "EHLO saus.bts.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751099AbZCJLqK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 07:46:10 -0400
Content-Disposition: inline
In-Reply-To: <20090310.043019.132650585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 10, 2009 at 04:30:19AM -0700, David Miller wrote:
> From: Marian =C4=8Eurkovi=C4=8D <md@bts.sk>
> Date: Tue, 10 Mar 2009 11:49:56 +0100
>=20
> > Sender does not have the relevant info to implement this - it might=
 be
> > connected by 10 GE to the highspeed backbone.
>=20
> Yes, the sender does indeed have this information, and using it is
> exactly what congestion control algorithms such as VEGAS try to do.
>=20
> They look at both round trip times and bandwith as they increase the
> send congestion window.  And if round trips increase without a
> corresponding increase in bandwidth, they stop increasing.

Yes, but that's actual bandwidth between sender and receiver, not
the hard BW limit of the receiver's NIC. My intention is just to introd=
uce
some safety belt preventing autotuning to increase the rx window
into MB ranges when RTT is very low.
