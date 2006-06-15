From: Russell Stuart <russell-tcatm@stuart.id.au>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling for ATM/ADSL
	(userspace)
Date: Thu, 15 Jun 2006 10:47:29 +1000
Message-ID: <1150332449.8605.40.camel@ras.pc.brisbane.lube>
References: <1150278040.26181.37.camel@localhost.localdomain>
	 <1150282625.3490.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jamal Hadi Salim <hadi@cyberus.ca>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 58.105.229.78.optusnet.com.au ([58.105.229.78]:48825 "EHLO
	adsl-kenny.stuart.id.au") by vger.kernel.org with ESMTP
	id S1750971AbWFOAsh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 20:48:37 -0400
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <1150282625.3490.23.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-14 at 11:57 +0100, Alan Cox wrote:
> The other problem I see with this code is it is very tightly tied to ATM
> cell sizes, not to solving the generic question of packetisation.

Others have made this point also.  I can't speak for Jesper,
but I did consider making it generic.  The issue was that 
doing so would add more code, but I don't personally know 
of any real world situation that would use the generic 
solution.  I didn't fancy the thought of arguing on these
lists for code that no one would actually use.

If someone could put up their hand and say "Hey, I need
this," then expanding the patch to accommodate them would
be a pleasure.  I like generic code too.


Russell

