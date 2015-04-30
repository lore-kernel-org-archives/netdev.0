From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of
 netfilter ingress hooks
Date: Thu, 30 Apr 2015 18:36:34 +0200
Message-ID: <20150430163634.GA3814@salvia>
References: <20150430003019.GE7025@acer.localdomain>
 <55417A3A.50405@iogearbox.net>
 <20150430004839.GG7025@acer.localdomain>
 <20150430011633.GA12674@Alexeis-MBP.westell.com>
 <20150430013452.GA7956@acer.localdomain>
 <554191F9.3010301@mojatatu.com>
 <20150430031138.GA8950@acer.localdomain>
 <5542182A.800@mojatatu.com>
 <20150430153317.GA3230@salvia>
 <554253B5.40801@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <554253B5.40801@iogearbox.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 30, 2015 at 06:09:25PM +0200, Daniel Borkmann wrote:
> I think both have different use cases, though, but on cls_bpf side you
> have maps infrastructure that is evolving as well. Not really speaking
> about the other remaining classifiers, however. I also don't want to go
> any further into this vim vs emacs debate. ;) And, personally, I also
> don't have any issue offering alternatives to users.
> 
> However, I still disagree with moving ingress behind this artificial
> barrier if it's just not necessary. I believe, in your RFC v1 patch,
> you had a second ingress hook as a static key for nft, I tend to like
> that much better consensus-wise. Both subsystems should not put
> unnecessary barriers into their way, really.

I'm evolving to think that it would be good to have a single entry
point for ingress filtering.

But where are the barriers? These unfounded performance claims are
simply absurd, qdisc ingress barely performs a bit better just because
it executes a bit less code and only in the single CPU scenario with
no rules at all.
