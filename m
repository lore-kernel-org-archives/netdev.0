From: jamal <hadi@cyberus.ca>
Subject: Re: Network activity LED trigger
Date: Fri, 02 Mar 2007 11:19:26 -0500
Message-ID: <1172852367.5016.20.camel@localhost>
References: <200703012241.49165.florian.fainelli@int-evry.fr>
	 <200703021358.52224.florian.fainelli@int-evry.fr>
	 <1172844668.4864.46.camel@localhost>
	 <200703021516.06638.florian.fainelli@int-evry.fr>
	 <1172848619.4845.17.camel@localhost>
	 <1172851428.11149.140.camel@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian.fainelli@int-evry.fr>,
	netdev@vger.kernel.org
To: Richard Purdie <rpurdie@rpsys.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:26732 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992576AbXCBQTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 11:19:30 -0500
Received: by wx-out-0506.google.com with SMTP id h31so806754wxd
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 08:19:29 -0800 (PST)
In-Reply-To: <1172851428.11149.140.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-02-03 at 16:03 +0000, Richard Purdie wrote:
> On Fri, 2007-03-02 at 10:16 -0500, jamal wrote:

> We already have this API, see drivers/leds ;-)

Very cool ;-> I was not aware of the existence of this API.
Actually i dont think it was available around 2.6.10.

> We have LEDs which show up in sysfs and can be controlled by userspace
> from there. They can also choose to be controlled by kernel LED
> 'triggers', for example. we have an IDE disk trigger which shows up
> activity on IDE disks. Florian would like to see a network trigger.
> 

This literally covers most of what i wanted; it may be too late to get
rid of that user space program but it is something i see you already
support;->

> The LED trigger code is quite generic and designed to have little impact
> on the subsystem its added to, at least in terms of code. As always,
> there will be some runtime overhead though. Ultimately it depends how
> complex you make the trigger (eg. how many options it has) and where 


Well, give me pointers and i will send you a patch for a board i
currently use:
http://download.intel.com/design/telecom/techspec/9635.pdf
which has GPIO LED.
I take it i would have to write a "driver" using your API?

> and how you hook it into the network subsystem. 
> I know little about the
> network subsystem so this is something others will have to advise on.

Other people may have different opionions: I cant think of something
useful from a network perspective mostly because you cant make it
generic enough i.e some boards will have LEDs for their NICs and some
wont. Just as some boards have activity LEDS for their IDE disks. IOW, I
think general purpose LEDs will probably be very dependent on the
shipping product.

other than that, great work!

cheers,
jamal

