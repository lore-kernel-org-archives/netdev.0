From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling for ATM/ADSL
	(userspace)
Date: Thu, 15 Jun 2006 09:03:11 -0400
Message-ID: <1150376591.5116.36.camel@jzny2>
References: <1150278040.26181.37.camel@localhost.localdomain>
	 <1150282625.3490.23.camel@localhost.localdomain>
	 <1150332449.8605.40.camel@ras.pc.brisbane.lube>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:64920 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1030389AbWFONDP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 09:03:15 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FqrVE-0004ke-Bw
	for netdev@vger.kernel.org; Thu, 15 Jun 2006 09:03:16 -0400
To: Russell Stuart <russell-tcatm@stuart.id.au>
In-Reply-To: <1150332449.8605.40.camel@ras.pc.brisbane.lube>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-15-06 at 10:47 +1000, Russell Stuart wrote:
> On Wed, 2006-06-14 at 11:57 +0100, Alan Cox wrote:
> > The other problem I see with this code is it is very tightly tied to ATM
> > cell sizes, not to solving the generic question of packetisation.
> 
> Others have made this point also.  I can't speak for Jesper,
> but I did consider making it generic.  The issue was that 
> doing so would add more code, but I don't personally know 
> of any real world situation that would use the generic 
> solution.  I didn't fancy the thought of arguing on these
> lists for code that no one would actually use.
> 
> If someone could put up their hand and say "Hey, I need
> this," then expanding the patch to accommodate them would
> be a pleasure.  I like generic code too.
> 

It is probably doable by just looking at netdevice->type and figuring
the link layer technology. Totally in user space and building the
compensated for tables there before telling the kernel (advantage is no
kernel changes and therefore it would work with older kernels as well).

cheers,
jamal



