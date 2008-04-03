From: Nate Case <ncase@xes-inc.com>
Subject: Re: [Pasemi-linux] I2C MDIO support for pasemi_mac driver
Date: Thu, 03 Apr 2008 08:45:27 -0500
Message-ID: <1207230327.19618.62.camel@localhost.localdomain>
References: <1204911643.8864.15.camel@localhost.localdomain>
	 <20080307183738.GA22366@lixom.net>  <20080307184854.GA23402@lixom.net>
	 <1205445473.8864.171.camel@localhost.localdomain>
	 <C3F69A6B-85D0-4FB4-834E-958A21C7577A@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	pasemi-linux@ozlabs.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xes-mad.com ([216.165.139.214]:33194 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753535AbYDCNpm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 09:45:42 -0400
In-Reply-To: <C3F69A6B-85D0-4FB4-834E-958A21C7577A@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-04-02 at 17:45 -0500, Andy Fleming wrote:
> My first instinct is that the current bus->id shouldn't be an int at  
> all (well, obviously not my *first* instinct, since that's what I did  
> the first time through).  So I like the idea of including a label in  
> the bus, but I'm not sure if it's necessary to add a new field.   
> Instead, I'd like to see bus->id converted to a char * or char [].  I  
> played around with this a bit today, and it requires a little more  
> work than it might at first seem, but is quite doable.
> 
> The question is whether that would solve your problem.  I think you  
> would then be able to register buses with the id "pas_gpio:xxx" or  
> "i2c:xxx", etc.

Thanks for the feedback.  Changing the bus ID to a string would solve my
problem, and I think this is a good way to do it.

- Nate Case <ncase@xes-inc.com>

