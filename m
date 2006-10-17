From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Tue, 17 Oct 2006 09:05:31 -0400
Message-ID: <1161090331.5555.10.camel@jzny2>
References: <44AC05A8.9030503@intel.com>
	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
	 <1152191018.5103.48.camel@jzny2>
	 <20060706.235909.78729229.davem@davemloft.net>
	 <1152275283.5341.144.camel@jzny2>  <4533D594.2070908@intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:39561 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750847AbWJQNFq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 09:05:46 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GZodW-0006aG-Th
	for netdev@vger.kernel.org; Tue, 17 Oct 2006 09:05:38 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <4533D594.2070908@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-16-10 at 11:55 -0700, Auke Kok wrote:
> jamal wrote:

> > I think when the e1000 says via ethtool "rx is on" - it means that it 
> > is _advertising_ flow control as opposed to detecting partner has flow
> > control capability.
> > Auke, can you also check this as well?
> 
> Just found this in my todo box - a bit late :(
> 
> yes, that appears to be the correct interpretation: we never read back the 
> detected FC  state from the hardware.
> 

It sounds to me that ethttool needs to have this semantic fix.
IOW, ethttool doesnt differentiate the two items:
a) advertised parameters.
b) link partner negotiated parameters.

and instead #a becomes #b after negotiation.

methinks this needs fixing. Dave? Jeff?

cheers,
jamal

