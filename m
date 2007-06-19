From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 21:55:49 +0400
Message-ID: <20070619175549.GA616@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru> <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru> <1182270529.4968.73.camel@localhost> <18040.5105.715624.286924@robur.slu.se> <1182275300.4968.83.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57269 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759588AbXFSR7Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 13:59:24 -0400
Content-Disposition: inline
In-Reply-To: <1182275300.4968.83.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 19, 2007 at 01:48:20PM -0400, jamal (hadi@cyberus.ca) wrote:
> On Tue, 2007-19-06 at 19:35 +0200, Robert Olsson wrote:
> 
> >  But Evgeniy is most likely using the same clocksource both for the mainline 
> >  and batch tests so there must be something different...
> 
> Iam curious though which one, from my notes on my laptop for that test
> machine:

Batch:
$ sudo cat
/sys/devices/system/clocksource/clocksource0/available_clocksource
tsc acpi_pm jiffies 

Mainline:
$ sudo cat
/sys/devices/system/clocksource/clocksource0/available_clocksource
tsc acpi_pm jiffies 

Config is exactly the same, so the same should be all parameters.

-- 
	Evgeniy Polyakov
