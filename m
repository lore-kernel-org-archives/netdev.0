From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next 00/43] Simplify netfilter and network namespaces
 (take 2)
Date: Thu, 18 Jun 2015 21:40:23 +0200
Message-ID: <20150618194023.GA3057@salvia>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
 <87r3pae5hn.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87r3pae5hn.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 17, 2015 at 10:09:40AM -0500, Eric W. Biederman wrote:
[...]
> There are a few extra cleanups in the first group of changes sprinkled
> in as I noticed a few other things as I was sorting out the network
> namespace computation logic.

This is a rather large patchset that address many pernet issues in the
netfilter codebase, I would classify them in:

1) Patches to prepare the ground for easier pernet integration.

2) Get rid of the dev_net(dev) ? ... : ...; pattern all around the
   netfilter code.

3) Missing pernet sysctl support is some spots, eg. br_netfilter.

4) Pernet hooks, probably the largest changeset in this pile and the
   most important one IMO.

So given that it's quite evident that netfilter netns support is
half-cooked and there's room for improvement in it, as we've been
receiving patches to partially add support on things that people
sporadically needed, could you please split this in several (smaller)
batches in logical changes for easier review?

On a different front, nfnetlink_log and nfnetlink_queue also still
lack of netns support so patches for that would be also appreciated in
another different round.

I'm going to take as much of small preparation patches that I can to
reduce your patchload:

1/43, 8/43, 16/43, 17/43, 18/43, 26/43

Thank you.
