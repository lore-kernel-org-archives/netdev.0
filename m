From: David Miller <davem@davemloft.net>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Tue, 17 Oct 2006 14:46:34 -0700 (PDT)
Message-ID: <20061017.144634.45875814.davem@davemloft.net>
References: <1152275283.5341.144.camel@jzny2>
	<4533D594.2070908@intel.com>
	<1161090331.5555.10.camel@jzny2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:63678
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750900AbWJQVq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 17:46:29 -0400
To: hadi@cyberus.ca
In-Reply-To: <1161090331.5555.10.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Tue, 17 Oct 2006 09:05:31 -0400

> It sounds to me that ethttool needs to have this semantic fix.
> IOW, ethttool doesnt differentiate the two items:
> a) advertised parameters.
> b) link partner negotiated parameters.
> 
> and instead #a becomes #b after negotiation.
> 
> methinks this needs fixing. Dave? Jeff?

The way I understand it the ethernet autonegotiation mechanisms don't
really give you a way to seperate these two things.

Either you negotiate the link and flow control settings, or nothing.
