From: Cong Wang <amwang@redhat.com>
Subject: Re: [PATCH 1/4] ipv6: add a new namespace for nf_conntrack_reasm
Date: Wed, 19 Sep 2012 09:54:05 +0800
Message-ID: <1348019645.11754.1.camel@cr0>
References: <1347975911-5655-1-git-send-email-amwang@redhat.com>
	 <1347975911-5655-2-git-send-email-amwang@redhat.com>
	 <20120918154509.GA19508@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120918154509.GA19508@1984>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2012-09-18 at 17:45 +0200, Pablo Neira Ayuso wrote:
> On Tue, Sep 18, 2012 at 09:45:08PM +0800, Cong Wang wrote:
> > +	if (!net_eq(net, &init_net)) {
> > +		table = kmemdup(table, sizeof(nf_ct_frag6_sysctl_table), GFP_KERNEL);
> 
> Sorry, you have to break lines at 80 chars.

Ok, will do.


