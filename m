From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch 1/1] ctnetlink: compute generic part of event more acurately
Date: Thu, 26 Mar 2009 13:38:13 +0100
Message-ID: <49CB7735.4060203@trash.net>
References: <20090325212521.149272388@jonathan.eitzenberger.org> <20090325213123.842307488@jonathan.eitzenberger.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Holger Eitzenberger <holger@eitzenberger.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090325213123.842307488@jonathan.eitzenberger.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Holger Eitzenberger wrote:
> On a box with most of the optional Netfilter switches turned off some
> of the NLAs are never send, e. g. secmark, mark or the conntrack
> byte/packet counters.  As a worst case scenario this may possibly
> still lead to ctnetlink skbs being reallocated in netlink_trim()
> later, loosing all the nice effects from the previous patches.
> 
> I try to solve that (at least partly) by correctly #ifdef'ing the
> NLAs in the computation.

Applied, thanks Holger.
