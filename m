From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 01/19] netfilter: nf_ct_sip: fix helper name
Date: Tue, 14 Aug 2012 02:00:56 +0200
Message-ID: <20120814000056.GA14483@1984>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <1344542943-11588-2-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1344542943-11588-2-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2012 at 10:08:45PM +0200, kaber@trash.net wrote:
> From: Patrick McHardy <kaber@trash.net>
> 
> Commit 3a8fc53a (netfilter: nf_ct_helper: allocate 16 bytes for the helper
> and policy names) introduced a bug in the SIP helper, the helper name is
> sprinted to the sip_names array instead of instead of into the helper
> structure. This breaks the helper match and the /proc/net/nf_conntrack_expect
> output.

Applied, thanks Patrick.
