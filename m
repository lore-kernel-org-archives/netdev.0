From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: nf_conntrack_sip: don't drop packets with
 offsets pointing outside the packet
Date: Sat, 6 Apr 2013 14:04:10 +0200
Message-ID: <20130406120410.GA14907@localhost>
References: <1365185610-2287-1-git-send-email-kaber@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1365185610-2287-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 05, 2013 at 08:13:30PM +0200, Patrick McHardy wrote:
> Some Cisco phones create huge messages that are spread over multiple packets.
> After calculating the offset of the SIP body, it is validated to be within
> the packet and the packet is dropped otherwise. This breaks operation of
> these phones. Since connection tracking is supposed to be passive, just let
> those packets pass unmodified and untracked.

Applied, thanks
