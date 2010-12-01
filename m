From: David Miller <davem@davemloft.net>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 01 Dec 2010 10:18:09 -0800 (PST)
Message-ID: <20101201.101809.71122121.davem@davemloft.net>
References: <AANLkTin6d=t6U28A-r=FznqE+5QuGXwg1tStOw-JXabg@mail.gmail.com>
	<1291192967.2856.492.camel@edumazet-laptop>
	<18eaf7d286236427b1632b9af62be513@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xiaosuo@gmail.com, wirelesser@gmail.com,
	netdev@vger.kernel.org
To: hagen@jauu.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60498
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752045Ab0LASRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 13:17:42 -0500
In-Reply-To: <18eaf7d286236427b1632b9af62be513@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hagen Paul Pfeifer <hagen@jauu.net>
Date: Wed, 01 Dec 2010 18:22:48 +0100

> On Wed, 01 Dec 2010 09:42:47 +0100, Eric Dumazet wrote:
> 
>> IMHO, a better pcap optimizer would be the first step.
> 
> +1
> 
> Optimizing complex filter rules is step one in the process of optimizing
> the packet processing. A JIT compiler like FreeBSD provides cannot polish a
> (pcap)turd. I thought Patrick was working on a generic filter mechanism for
> netfilter!? ... ;)

Yes, and we spoke at the netfilter workshop about making that interpreter
available to socket filters and the packet classifier layer.

However, I think it's still valuable to write a few JIT compilers for
the existing BPF stuff.  I considered working on a sparc64 JIT just to
see what it would look like.

If people work on the BPF optimizer and BPF JITs in parallel, we'll have
both ready at the same time.  win++
