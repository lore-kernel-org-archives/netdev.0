From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf-next] netfilter: xt_bpf: support ebpf
Date: Mon, 05 Dec 2016 14:59:09 -0800
Message-ID: <1480978749.18162.561.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1480969684-74414-1-git-send-email-willemdebruijn.kernel@gmail.com>
         <1480972006.18162.559.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161205213001.GA16819@breakpoint.cc> <20161205223415.GA14689@salvia>
         <20161205224051.GB16819@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
        Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, Willem de Bruijn <willemb@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20161205224051.GB16819@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-12-05 at 23:40 +0100, Florian Westphal wrote:

> Fair enough, I have no objections to the patch.

An additional question is about PATH_MAX :

Is it guaranteed to stay at 4096 forever ?

To be safe, maybe we should use a constant of our own.


