From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000]: flow control on by default - good idea really?
Date: Fri, 07 Jul 2006 08:28:03 -0400
Message-ID: <1152275283.5341.144.camel@jzny2>
References: <44AC05A8.9030503@intel.com>
	 <Pine.LNX.4.64.0607052241230.12611@bizon.gios.gov.pl>
	 <1152191018.5103.48.camel@jzny2>
	 <20060706.235909.78729229.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@intel.com, Robert.Olsson@data.slu.se,
	john.ronciak@intel.com, greearb@candelatech.com, jgarzik@pobox.com,
	olel@ans.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:3543 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932110AbWGGM2J
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 08:28:09 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FypRL-0002U3-RA
	for netdev@vger.kernel.org; Fri, 07 Jul 2006 08:28:11 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060706.235909.78729229.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-07 at 23:59 -0700, David Miller wrote:

> 
> It's autonegotiated, check you kernel message logs when the link
> came up, you'll see this:
> 
> tg3: eth0: Flow control is on for TX and on for RX.
> 

yikes - yes, this would be it.

I  could be wrong and i will double check:
I think when the e1000 says via ethtool "rx is on" - it means that it 
is _advertising_ flow control as opposed to detecting partner has flow
control capability.
Auke, can you also check this as well?

cheers,
jamal 


