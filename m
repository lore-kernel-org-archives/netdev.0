From: "Ed L. Cashin" <ecashin@coraid.com>
Subject: Re: 2.6.16.11 BUG at tg3.c:2917
Date: Thu, 27 Apr 2006 17:04:54 -0400
Message-ID: <20060427210454.GF29045@coraid.com>
References: <20060427165234.GC29045@coraid.com> <1146152724.11406.3.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.coraid.com ([65.14.39.133]:2139 "EHLO coraid.com")
	by vger.kernel.org with ESMTP id S1751666AbWD0VQL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 17:16:11 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1146152724.11406.3.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 27, 2006 at 08:45:24AM -0700, Michael Chan wrote:
> On Thu, 2006-04-27 at 12:52 -0400, Ed L. Cashin wrote:
> > -- [please bite here ] ---------
> > Kernel BUG at drivers/net/tg3.c:2917
> > invalid opcode: 0000 [1] SMP 
> > CPU 0 
> 
> Most likely caused by IO re-ordering. Try the test patch in this
> discussion:
> 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=113890239404768&w=2

I'm afraid I might be generating noise here.  After my initial post I
found that I cannot trigger a panic without the latest changes to the
aoe driver in place.  I haven't been able to trigger a panic using the
aoe driver inside 2.6.16.11.

I think we've identified the problem in the aoe driver, but if I'm
wrong, I will certainly try the TG3_FLAG_MBOX_WRITE_REORDER patch you
mention.

-- 
  Ed L Cashin <ecashin@coraid.com>
