From: David Miller <davem@davemloft.net>
Subject: Re: [Q/RFC] BPF use in broader scope
Date: Thu, 29 Mar 2012 04:43:24 -0400 (EDT)
Message-ID: <20120329.044324.1881363222808734381.davem@davemloft.net>
References: <20120329075410.GC2098@minipsycho>
	<1333008145.2325.275.camel@edumazet-glaptop>
	<20120329083149.GD2098@minipsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com, matt@ozlabs.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758230Ab2C2Iom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2012 04:44:42 -0400
In-Reply-To: <20120329083149.GD2098@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 29 Mar 2012 10:31:49 +0200

> Thu, Mar 29, 2012 at 10:02:25AM CEST, eric.dumazet@gmail.com wrote:
>>On Thu, 2012-03-29 at 09:54 +0200, Jiri Pirko wrote:
>>
>>> Yep, I'm aware. I must admit that the JIT code scares me a litte :(
>>> 
>>
>>If you add a new XOR instruction in interpreter only, JIT compiler will
>>automatically aborts, so no risk.
>>
>>Each arch maintainer will add the support for the new instructions as
>>separate patches.
>>
>>So you can focus on net/core/filter.c file only.
>>
> 
> Ok - I can do this for 2). But for 3) JITs need to be modified. So I
> would like to kindly ask you and Matt if you can do this modification so
> bpf_func takes pointer to mem (scratch store) as second parameter. I'm
> sure it's very easy for you to do.

The ARM JIT just went into Linus's tree as well.
