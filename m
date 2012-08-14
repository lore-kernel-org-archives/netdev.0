From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 02/19] netfilter: nf_ct_sip: fix IPv6 address parsing
Date: Tue, 14 Aug 2012 02:19:38 +0200
Message-ID: <20120814001938.GB14483@1984>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <1344542943-11588-3-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1344542943-11588-3-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2012 at 10:08:46PM +0200, kaber@trash.net wrote:
> From: Patrick McHardy <kaber@trash.net>
> 
> Within SIP messages IPv6 addresses are enclosed in square brackets in most
> cases, with the exception of the "received=" header parameter. Currently
> the helper fails to parse enclosed addresses.
> 
> This patch:
> 
> - changes the SIP address parsing function to enforce square brackets
>   when required, and accept them when not required but present, as
>   recommended by RFC 5118.
> 
> - adds a new SDP address parsing function that never accepts square
>   brackets since SDP doesn't use them.
> 
> With these changes, the SIP helper correctly parses all test messages
> from RFC 5118 (Session Initiation Protocol (SIP) Torture Test Messages
> for Internet Protocol Version 6 (IPv6)).

Applied, thanks Patrick.
