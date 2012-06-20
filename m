From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH] net: Update netdev_alloc_frag to work more efficiently
 with TCP and GRO
Date: Wed, 20 Jun 2012 13:10:05 -0700
Message-ID: <4FE22E1D.3010006@intel.com>
References: <20120620004306.17814.58369.stgit@gitlad.jf.intel.com>  <1340170590.4604.784.camel@edumazet-glaptop> <4FE1FABF.6040309@intel.com>  <4FE20511.4000206@intel.com> <1340217693.4604.1576.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41063 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754266Ab2FTUKF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 16:10:05 -0400
In-Reply-To: <1340217693.4604.1576.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/20/2012 11:41 AM, Eric Dumazet wrote:
> On Wed, 2012-06-20 at 10:14 -0700, Alexander Duyck wrote:
>
>> Actually I think I just realized what the difference is.  I was looking
>> at things with LRO disabled.  With LRO enabled our hardware RSC feature
>> kind of defeats the whole point of the GRO or TCP coalescing anyway
>> since it will stuff 16 fragments into a single packet before we even
>> hand the packet off to the stack.
> I noticed LRO was now 'off' by default on ixgbe (net-next tree), I am
> pretty sure it was 'on' some months ago ?
It should be on by default unless you are doing some routing.  In that
case as soon as the interface comes up the LRO is disabled by the stack.

Thanks,

Alex
