From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: ipset: deduplicate prefixlen maps
Date: Mon, 31 Jul 2017 19:01:10 +0200
Message-ID: <20170731170110.GA4006@salvia>
References: <20170720181300.20955-1-aconole@bytheb.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Florian Westphal <fw@strlen.de>
To: Aaron Conole <aconole@bytheb.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170720181300.20955-1-aconole@bytheb.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 20, 2017 at 02:13:00PM -0400, Aaron Conole wrote:
> The prefixlen maps used here are identical, and have been since
> introduction.  It seems to make sense to use a single large map,
> that the preprocessor will fill appropriately.

Applied, thanks.
