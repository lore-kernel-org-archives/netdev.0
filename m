From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2 v2 nf-next] net: bridge: don't register netfilter call_iptables hooks by default
Date: Thu, 18 Sep 2014 21:31:33 +0200
Message-ID: <d6c03eac-ce32-4728-85cf-2c385613a7df@email.android.com>
References: <1410969137-11885-1-git-send-email-fw@strlen.de> <20140918133511.GA8740@salvia>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20140918133511.GA8740@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 18. September 2014 15:35:52 MESZ, Pablo Neira Ayuso <pablo@netfilter.org> wrote:

>Unless I'm missing anything, I think br_netfilter should have been a
>separated module since the beginning. 

Yeah absolutely. Basic rule: don't impose the costs of your cool new feature on all the people who will never need it.

Great someone finally fixes this up. Long term we still need a sane design for this though, some direct way of bridging to interact with conntrack, nftables provides for the rest.

