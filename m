From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Thu, 30 Apr 2015 11:24:57 +0200
Message-ID: <5541F4E9.8080009@iogearbox.net>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233205.GA3416@salvia> <20150430003740.GF7025@acer.localdomain> <55417F80.4000506@iogearbox.net> <20150430014316.GB7956@acer.localdomain> <554194E9.5040002@mojatatu.com> <20150430032921.GB8950@acer.localdomain> <20150430040535.GH8950@acer.localdomain> <20150430060256.GA12790@Alexeis-MBP.westell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150430060256.GA12790@Alexeis-MBP.westell.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/30/2015 08:02 AM, Alexei Starovoitov wrote:
...
> My point is that I agree that cleanup of ingress qdisc is needed.
> I disagree with drastic measures.
> Just add your nf_hook to ingress and let's see how things evolve.
> We have rx_handler and all of ptype hooks in there. One can argue
> that rx_handler overlaps with nf_hook too ? ;)
> We cannot generalize them all under one 'hook' infra.
> nf needs to do nf_hook_state_init() and pass it around which
> no one else needs. That's the cost others should not pay.

+1
