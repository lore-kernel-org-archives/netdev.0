From: bert hubert <ahu@ds9a.nl>
Subject: Re: (udp-en/decap broken in 2.6.8-rc2?) Re: ipsec, nat-t, iproute2?
Date: Sat, 31 Jul 2004 14:18:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040731121828.GA29497@outpost.ds9a.nl>
References: <20040731083456.GA24761@outpost.ds9a.nl> <E1Bqr9r-0004av-00@gondolin.me.apana.org.au> <20040731112048.GA27893@outpost.ds9a.nl> <20040731115230.GA18537@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="AhhlLboLdkugWU4S"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20040731115230.GA18537@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--AhhlLboLdkugWU4S
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sat, Jul 31, 2004 at 09:52:30PM +1000, Herbert Xu wrote:
> On Sat, Jul 31, 2004 at 01:20:49PM +0200, bert hubert wrote:
> > 
> > setsockopt(3, SOL_UDP, 100, [1], 4)     = 0
> 
> You chose NON_IKE.

I've tried it both ways, both don't work. I should have mentioned that.

I've attached the code that tries to setup the receiving end so things work.
It is in c++, I hope that does not offend too many people.

g++ udpencap.cc -o udpencap

You can strace it to see what it is doing in any case.

Thanks again.

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO

--AhhlLboLdkugWU4S
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="udpencap.tar.gz"
Content-Transfer-Encoding: base64

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
pjWtaU1rWtOa1rT/2/ZvkP2GRgBQAAA=

--AhhlLboLdkugWU4S--
