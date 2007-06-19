From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 13:48:20 -0400
Message-ID: <1182275300.4968.83.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru>
	 <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:60514 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753467AbXFSRsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 13:48:24 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1908197wxc
        for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 10:48:23 -0700 (PDT)
In-Reply-To: <18040.5105.715624.286924@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-19-06 at 19:35 +0200, Robert Olsson wrote:

>  But Evgeniy is most likely using the same clocksource both for the mainline 
>  and batch tests so there must be something different...

Iam curious though which one, from my notes on my laptop for that test
machine:

# cat /sys/devices/system/clocksource/clocksource0/available_clocksource
acpi_pm jiffies tsc

# cat /sys/devices/system/clocksource/clocksource0/current_clocksource
acpi_pm

OTOH, on my laptop:
-------
hadi@lilsol:~$ sudo cat /sys/devices/system/clocksource/clocksource0/
available_clocksource  current_clocksource
hadi@lilsol:~$ sudo
cat /sys/devices/system/clocksource/clocksource0/current_clocksource
hpet
---------------

cheers,
jamal

PS:- i wont be able to respond for another 24 hrs or so.

