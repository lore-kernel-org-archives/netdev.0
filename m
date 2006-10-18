From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Wed, 18 Oct 2006 09:35:40 -0400
Message-ID: <1161178540.5240.16.camel@jzny2>
References: <44AC05A8.9030503@intel.com>
	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
	 <1152191018.5103.48.camel@jzny2>
	 <20060706.235909.78729229.davem@davemloft.net>
	 <1152275283.5341.144.camel@jzny2>  <4533D594.2070908@intel.com>
	 <1161090331.5555.10.camel@jzny2>  <453544EF.4000502@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:36511 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1161033AbWJROcP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 10:32:15 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GaCSw-0001ro-Rw
	for netdev@vger.kernel.org; Wed, 18 Oct 2006 10:32:18 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <453544EF.4000502@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-17-10 at 14:02 -0700, Auke Kok wrote:

> For now, we should really report the FC status in e1000 at link up time. Jamal: this 
> should help you out for now, I'll send something like this upstream later on.
> 

Thanks - this puts you at par with the tg3 at least.


On Tue, 2006-17-10 at 14:46 -0700, David Miller wrote: 
> From: jamal <hadi@cyberus.ca>
> Date: Tue, 17 Oct 2006 09:05:31 -0400
> 
> > It sounds to me that ethttool needs to have this semantic fix.
> > IOW, ethttool doesnt differentiate the two items:
> > a) advertised parameters.
> > b) link partner negotiated parameters.
> > 
> > and instead #a becomes #b after negotiation.
> > 
> >
> > methinks this needs fixing. Dave? Jeff?
> 
> The way I understand it the ethernet autonegotiation mechanisms don't
> really give you a way to seperate these two things.
> 
> Either you negotiate the link and flow control settings, or nothing.

True - but I was thinking more of the state stored in the driver
either by ethtool or some other part of the driver.

If i remember correctly, Donald Beckers old mii tool was able to 
display
"here's what you have configured the driver for link and flow control and 
these are what i advertise to link peers"
and
"here's what current negotiated link and flow control parameters with 
link peer"

That distinction doesnt exist with ethtool. Or i am missing something.

cheers,
jamal

