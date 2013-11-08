From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next 1/2] ip6_output: fragment outgoing reassembled skb properly
Date: Fri, 8 Nov 2013 23:20:42 +0100
Message-ID: <20131108222042.GA1963@order.stressinduktion.org>
References: <1383756740-7392-2-git-send-email-jiri@resnulli.us> <20131107.185453.1341640661253119352.davem@davemloft.net> <20131108075201.GA2455@minipsycho.orion> <20131108.144915.635810300359291522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: jiri@resnulli.us, netdev@vger.kernel.org, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, fw@strlen.de
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131108.144915.635810300359291522.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 08, 2013 at 02:49:15PM -0500, David Miller wrote:
> Perhaps I don't understand completely the intentions and logic of
> dst_allfrag() in the ipv6 case, and maybe you can explain it to me.

dst_allfrag gets active if we receive a PMTU packet indicating a MTU
smaller than 1280. Of course IPv6 may not go below 1280 but this indicates
e.g. a IPv6->IPv4 migration technology is on the path which needs the
IPv6 fragment header and its fragment id to generate IPv4 fragment ids
out of the IPv6 ones to produce IPv4 fragments just after this migration
router which could well be smaller than 1280.

Maybe this does help a bit,

  Hannes

