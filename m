From: jamal <hadi@cyberus.ca>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 16:10:32 -0400
Message-ID: <1148501433.5325.52.camel@jzny2>
References: <20060523.182217.59656237.davem@davemloft.net>
	 <447412CA.50303@ipom.com> <4474A489.4080308@garzik.org>
	 <20060524185644.GF22881@ipom.com> <4474AE92.3030501@garzik.org>
	 <20060524191442.GG22881@ipom.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:43143 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S932257AbWEXUKl
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 16:10:41 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Fizgm-0005Eq-Ty
	for netdev@vger.kernel.org; Wed, 24 May 2006 16:10:40 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <20060524191442.GG22881@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-24-05 at 12:14 -0700, Phil Dibowitz wrote:

> 
> Right, I'm aware there are other ways of doing this - I've written scripts to
> record a hundreds of numbers, and then subtract them from each other. But
> those scripts are work arounds 

It is not a work around, _it is design intent_. It is what network
management tools have been expecting since the days of the caveman.
These stats are supposed to be monotonically increasing; if that
behavior is contradicted, a rollover of the counters is assumed.

> for a feature _lacking_ in the kernel. A
> feature that, as I've mentioned, is supported on any piece of networking gear
> (and of course, lets not forget there's a specific option in the kernel config
> *just* for "behave like a router").

Can you provide some link to a vendor that allows resetting ethernet
stats? I am almost certain, if they do they will have something or other
which indicates that such a reset happened. It is also easier for cisco
to have none standard feature "as of ios 15.16" which could support such
behavior because they bundle everything including network management
tools. We dont have that luxury. The BSDs may actually get away with it
because they bundle user space apps as well. Perhaps some
random Linux vendor as well..

> If my patch was invasive and broke things, 

It _does break_ things for all known management apps. 
This is not to say it is not useful for testing, development or
debugging (which is what you seem to be using it for) but it does mean
it is broken. 

cheers,
jamal




