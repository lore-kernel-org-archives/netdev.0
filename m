From: Petr Vandrovec <vandrove@vc.cvut.cz>
Subject: Re: af_packet & CHECKSUM_HW
Date: Wed, 19 Nov 2003 16:11:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119151149.GA30100@vana.vc.cvut.cz>
References: <20031115024434.GA12276@gondor.apana.org.au> <Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com> <20031116205146.GA8477@gondor.apana.org.au> <20031117194452.GB18448@vana.vc.cvut.cz> <20031117123047.55377d3a.davem@redhat.com> <20031118132137.GA23732@vana.vc.cvut.cz> <20031118174612.48c0854e.davem@redhat.com> <20031119123535.GA11108@vana.vc.cvut.cz> <1069254105.1025.26.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, herbert@gondor.apana.org.au,
        jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1069254105.1025.26.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Nov 19, 2003 at 10:01:45AM -0500, jamal wrote:
> 
> I think this sort of stuff will greatly benefit from the tc extensions
> that i have been working on. 
> instead of hacking on ptype you can instead write little modules that
> do speacilized work (like computing checksums) or dropping packets
> or setting these flags that can be later used for doing extra work.
> The code executes before the ptype level execution and using the u32
> classifier you can grop any part of the packet. I can send you a patch
> if you want to give it a shot.

I'll gladly look at it. From your short description it looks like that
it could solve also our second longstanding problem: we cannot block 
host->guest packets from hitting wire, and if guest communicates only 
with host (this traffic does not hit wire as it is injected as if 
received from network card) then switches on the network do not know 
where guest lives, and these packets then flood whole network.
					Thanks,
						Petr Vandrovec
