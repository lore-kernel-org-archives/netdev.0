From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] netfilter: nf_tables: check for NULL in
 nf_tables_newchain pcpu stats allocation
Date: Wed, 22 Oct 2014 14:09:05 +0200
Message-ID: <20141022120905.GA25795@salvia>
References: <20141021090821.GA31730@kria>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kadlec@blackhole.kfki.hu,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141021090821.GA31730@kria>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 21, 2014 at 11:08:21AM +0200, Sabrina Dubroca wrote:
> alloc_percpu returns NULL on failure, not a negative error code.

Good catch. Applied, thanks.
