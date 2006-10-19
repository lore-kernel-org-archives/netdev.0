From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] [NET] Size listen hash tables using backlog hint
Date: Thu, 19 Oct 2006 11:11:35 +0200
Message-ID: <200610191111.36250.dada1@cosmosbay.com>
References: <45371C8D.20603@cosmosbay.com> <200610191029.00720.dada1@cosmosbay.com> <20061019.014120.78710373.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:5060 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1030357AbWJSJLh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 05:11:37 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061019.014120.78710373.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 19 October 2006 10:41, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Thu, 19 Oct 2006 10:29:00 +0200
>
> > Cons :
> > TLB cost
>
> For those hot x86 and x86_64 cpus you tend to be using, this
> particular cost is relatively small.  :-) It's effectively like
> another memory reference in the worst case, in the best case
> it's "free".

Well, it was a private joke with you, as you  *use* machines that take a fault 
on a TLB miss :) 

BTW I do care of old machines too...
