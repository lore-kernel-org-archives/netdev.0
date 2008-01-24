From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [IPV4 0/9] TRIE performance patches
Date: Thu, 24 Jan 2008 08:18:21 -0800
Message-ID: <20080124081821.018476cd@deepthought>
References: <20080122233733.404145234@linux-foundation.org>
	<18327.18935.137799.285515@robur.slu.se>
	<20080123154933.233c4909@deepthought>
	<18328.23597.205001.332244@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54796 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752642AbYAXQV4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 11:21:56 -0500
In-Reply-To: <18328.23597.205001.332244@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Jan 2008 10:36:45 +0100
Robert Olsson <Robert.Olsson@data.slu.se> wrote:

> 
> Stephen Hemminger writes:
> 
>  > Dumping by prefix is possible, but unless 32x slower. Dumping in
>  > address order is just as logical. Like I said, I'm investigating what
>  > quagga handles.
> 
>  How about taking a snapshot to in address order (as you did) to some 
>  allocated memory, returning from that memory in prefix order? This would 
>  solve the  -EBUSY too and give a consistent view of the routing table at
>  the time for the dump/snapshot.
> 
>  Cheers
> 					--ro

Snapshotting is going to work, because of scale and because the kernel can't
tell when application is going to come back.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
