From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2.6.28] cxgb3 - Fix LRO misalignment
Date: Thu, 15 Jan 2009 17:57:07 -0800
Message-ID: <496FE973.1060106@hp.com>
References: <20090116004829.7437.52798.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	leedom@chelsio.com
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:29098 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755983AbZAPB5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 20:57:10 -0500
In-Reply-To: <20090116004829.7437.52798.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Divy Le Ray wrote:
> From: Divy Le Ray <divy@chelsio.com>
> 
> The lro manager's frag_align_pad setting was missing,
> leading to misaligned access to the skb passed up
> to the stack.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

I have tried this in a tree I have, and where I was once seeing unaligned access 
messages on an ia64 system with LRO enabled, now I see none.

Tested-by: Rick Jones <rick.jones2@hp.com>

rick jones
