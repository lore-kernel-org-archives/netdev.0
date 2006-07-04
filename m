From: jamal <hadi@cyberus.ca>
Subject: Re: [e1000]:  flow control on by default - good idea really?
Date: Tue, 04 Jul 2006 15:20:39 -0400
Message-ID: <1152040839.5276.25.camel@jzny2>
References: <1152033116.5276.22.camel@jzny2>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	Robert Olsson <Robert.Olsson@data.slu.se>,
	john.ronciak@intel.com, Ben Greear <greearb@candelatech.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:64162 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932345AbWGDTUx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 15:20:53 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1FxqS6-0004Px-Kg
	for netdev@vger.kernel.org; Tue, 04 Jul 2006 15:20:54 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <1152033116.5276.22.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-04-07 at 13:11 -0400, jamal wrote:
> CCing anybody who may have stakes on this. Ignore the email if this
> doesnt interest you.
> Ok, folks - i had deferred this discussion but it bit me in the ass. 
> I just spend an hour debugging it (and in the process blew up a gbic i
> borrowed, so my day aint going well since i actually have to pay for
> this and cant really do the testing i was planning to;-<).
>  
> I have a device connected to a e1000 that was erroneously advertising
> both tx/rx flow control but wasnt properly reacting to it. 
> The default setup on the e1000 has rx flow control turned on.
> I was sending at wire rate gige from the device - which is about
> 1.48Mpps. The e1000 was in turn sending me flow control packets
> as per default/expected behavior. Unfortunately, it was sending
> a very large amount of packets. At one point i was seeing upto
> 1Mpps and on average, the flow control packets were consuming
> 60-70% of the bandwidth. Even when i fixed this behavior to act
> properly, allowing flow control on consumed up to 15% of the bandwidth. 
> Clearly, this is a bad thing. Yes, the device in the first instance was
> at fault. But i have argued in the past that NAPI does just fine without
> flow control being turned on, so even chewing 5% of bandwidth on flow
> control is a bad thing..
> 
> As a compromise, can we declare flow control as an advanced feature
> and turn it off by default? People who feel it is valuable and know
> what they are doing can turn it off.

I meant turn it on.

BTW, As an addendum this default behavior changed around 2.6.16 it
seems.

cheers,
jamal

