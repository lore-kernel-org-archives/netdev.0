From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 03/19] netfilter: nf_nat_sip: fix via header
 translation with multiple parameters
Date: Tue, 14 Aug 2012 02:28:57 +0200
Message-ID: <20120814002857.GC14483@1984>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <1344542943-11588-4-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1344542943-11588-4-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2012 at 10:08:47PM +0200, kaber@trash.net wrote:
> From: Patrick McHardy <kaber@trash.net>
> 
> Via-headers are parsed beginning at the first character after the Via-address.
> When the address is translated first and its length decreases, the offset to
> start parsing at is incorrect and header parameters might be missed.
> 
> Update the offset after translating the Via-address to fix this.

Applied, thanks Patrick.
