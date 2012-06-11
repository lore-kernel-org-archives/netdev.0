From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: net: nfc: BUG and panic in accept() on 3.5-rc2
Date: Mon, 11 Jun 2012 18:55:59 +0200
Message-ID: <1339433759.4999.64.camel@lappy>
References: <1339423241.4999.53.camel@lappy>
	 <20120611144134.GX22557@sortiz-mobl>
	 <1339425693.6001.2268.camel@edumazet-glaptop>
	 <1339426241.4999.62.camel@lappy>
	 <1339426726.6001.2309.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Samuel Ortiz <sameo@linux.intel.com>,
	David Miller <davem@davemloft.net>,
	lauro.venancio@openbossa.org, aloisio.almeida@openbossa.org,
	Dave Jones <davej@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1339426726.6001.2309.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-06-11 at 16:58 +0200, Eric Dumazet wrote:
> On Mon, 2012-06-11 at 16:50 +0200, Sasha Levin wrote:
> 
> > Eric, Is there something that documents at what state each of the
> > callbacks in the network subsystem can be called? Like a big flow chart
> > of some sorts?
> > 
> > I'm asking because I've looked at this as well before sending this mail,
> > and while the fix does look trivial, I wasn't sure whether it is really
> > the correct fix, or the problem is that this callback wasn't supposed be
> > called at all so something else is broken (we had such issue with
> > namespaces and unshare() not long ago).
> > 
> 
> I am not aware of such 'document'.
> 
> Things change, and only *good* reference is actual source code.
> 
> Now, take a look at sock_graft()/sock_orphan()/inet_release() ...

I see.

I grepped for release callbacks and the first few in the result (atm,
ax_25) did check for !sk, so I guess I'll just follow what I see in
other code in the future :)
