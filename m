From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 00/15] Simplify netfilter and network namespaces
Date: Mon, 15 Jun 2015 10:06:27 -0500
Message-ID: <87twu9nh8s.fsf@x220.int.ebiederm.org>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
	<20150615070622.GA3315@salvia>
Mime-Version: 1.0
Content-Type: text/plain
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
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150615070622.GA3315@salvia> (Pablo Neira Ayuso's message of
	"Mon, 15 Jun 2015 09:06:22 +0200")
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pablo Neira Ayuso <pablo@netfilter.org> writes:

> Hi Eric,
>
> On Sun, Jun 14, 2015 at 10:07:30PM -0500, Eric W. Biederman wrote:
>> 
>> While looking into what it would take to route packets out to network
>> devices in other network namespaces I started looking at the netfilter
>> hooks, and there is a lot of nasty code to figure out which network
>> namespace to filter the packets in.
>>
>> Just passing the network namespace into the netfilter hooks looks like a
>> significant simplication in the code, and worth it as the first thing
>> most netfilter hooks do is compute the network namespace.
>> 
>> We probably even want per network namespace netfilter hooks as nftables
>> tries (and fails to use).  nftables currently has a fairly serious bug
>> where the tables for one network namespace run for packets in all
>> network namespaces.  I do not have a fix yet but I think this patchset
>> making it easy to get at the network namespace is a good starting
>> place for a fix.
>
> I have a patchset that is almost ready to convert netfilter to pernet
> hooks, it partially clashes with this. Will send it out today and will
> Cc you so you can review it.
>
> I think it should take me little time to rebase it on top of yours.
> It's rather large changeset, which quite a lot of boiler plate code
> though.

Hmm.

I will wait and take a look.  I think going from where I am to pernet
netfilter hooks is about one simple patch, so I don't know where the
large about of boiler plate comes from.  I think I will code that up so
I can verify that and we can compare notes later today.

Eric

