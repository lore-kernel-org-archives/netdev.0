From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 0/2] Toeplitz hashing
Date: Mon, 23 Sep 2013 16:16:34 -0700
Message-ID: <5240CBD2.1020709@hp.com>
References: <alpine.DEB.2.02.1309231534010.23714@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:23659 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752394Ab3IWXQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 19:16:37 -0400
In-Reply-To: <alpine.DEB.2.02.1309231534010.23714@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/23/2013 03:41 PM, Tom Herbert wrote:
> There's also the possibility of calculating the Toeplitz hash for a
> connection in order to deduce which RSS queue the connection maps
> to, and thus allow a poor man's aRFS (idea from Jesse Brandeburg).

Perhaps the answer is in the meaning of the leading 'a' in aRFS but 
doesn't one still depend on the thread of execution handling only one 
flow for that to work effectively?  Or would flows be assigned to 
threads of execution based on the Toeplitz hash of the connections?

rick jones
