From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1] netfilter: cttimeout: fix buffer overflow
Date: Wed, 21 Nov 2012 23:54:36 +0100
Message-ID: <20121121225436.GB19941@1984>
References: <1353497858-29404-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1353497858-29404-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2012 at 12:37:38PM +0100, Florian Westphal wrote:
> Chen Gang reports:
> the length of nla_data(cda[CTA_TIMEOUT_NAME]) is not limited in server side.
> 
> And indeed, its used to strcpy to a fixed-sized buffer.
> 
> Fortunately, nfnetlink users need CAP_NET_ADMIN.

Good catch, applied thanks.
