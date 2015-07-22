From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf] netfilter: Support expectations in different zones
Date: Wed, 22 Jul 2015 21:57:27 +0200
Message-ID: <20150722195727.GA10693@salvia>
References: <1437539851-65437-1-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1437539851-65437-1-git-send-email-joestringer@nicira.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 21, 2015 at 09:37:31PM -0700, Joe Stringer wrote:
> When zones were originally introduced, the expectation functions were
> all extended to perform lookup using the zone. However, insertion was
> not modified to check the zone. This means that two expectations which
> are intended to apply for different connections that have the same tuple
> but exist in different zones cannot both be tracked.
> 
> Fixes: 5d0aa2ccd4 (netfilter: nf_conntrack: add support for "conntrack zones")

Applied, thanks Joe.
