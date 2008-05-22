From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use krealloc() in nf_conntrack_extend.c V2
Date: Thu, 22 May 2008 21:09:26 +0200
Message-ID: <4835C4E6.3050005@trash.net>
References: <Pine.LNX.4.64.0805222145320.6071@sbz-30.cs.Helsinki.FI> <Pine.LNX.4.64.0805222155150.6294@sbz-30.cs.Helsinki.FI> <4835C41E.2010502@trash.net> <4835C45F.5030201@cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mpm@selenic.com, clameter@sgi.com
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4835C45F.5030201@cs.helsinki.fi>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pekka Enberg wrote:
> Patrick McHardy wrote:
>> Unfortunately this means we'll always have to reallocate, even
>> if there's still some room left from the previous allocation.
>> Any chance to avoid that?
>
> No, no, krealloc() avoids reallocation if there's enough room in the 
> buffer to fit newlen.

Great, thanks for the explanation. Is this patch targeted
at 2.6.26 or 2.6.27?

