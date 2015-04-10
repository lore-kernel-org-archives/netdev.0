From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 0/7 RFC] Netfilter/nf_tables ingress support
Date: Fri, 10 Apr 2015 22:09:01 +0200
Message-ID: <20150410200901.GB5968@salvia>
References: <1428668142-4006-1-git-send-email-pablo@netfilter.org>
 <20150410132205.GF23070@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, kaber@trash.net,
	netdev@vger.kernel.org, davem@davemloft.net
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150410132205.GF23070@casper.infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 10, 2015 at 02:22:05PM +0100, Thomas Graf wrote:
> On 04/10/15 at 02:15pm, Pablo Neira Ayuso wrote:
> > This patchset adds the Netfilter hook at the ingress path, in a per-device
> > fashion. This also comes with the new nf_tables 'netdev' family support to
> > provide access to users to the existing nf_tables features. This includes the
> > transactional netlink API and the enhanced set infrastructure.  Several patches
> > come in first place to prepare this support, including the refactoring of
> > __netif_receive_skb_core() to accomodate the new hook.
> 
> Is the goal to eventually replace ebtables with this?

No, nftables comes with a bridge family that will eventually replace
ebtables.
