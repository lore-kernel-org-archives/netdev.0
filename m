From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 20:35:57 +0400
Message-ID: <20070619163557.GA17942@2ka.mipt.ru>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com> <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru> <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru> <1182270529.4968.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:54097 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750755AbXFSQgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 12:36:45 -0400
Content-Disposition: inline
In-Reply-To: <1182270529.4968.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 19, 2007 at 12:28:49PM -0400, jamal (hadi@cyberus.ca) wrote:
> On Tue, 2007-19-06 at 18:00 +0400, Evgeniy Polyakov wrote:
> 
> > pktgen reults are quite poor:
> > batch (changed from default script: count reduced, clone increased to 10k)
> > 241319pps 115Mb/sec
> > 
> > mainline (the same script, on start it wrote about unsupported batch_low
> > parameter:
> > 497520pps 238Mb/sec
> 
> What is your kernel config in regards to HRES timers? Robert mentioned
> to me that the clock source maybe causing issues with pktgen (maybe even
> qos). 
> Robert, insights?
> 
> In my case, I have:
> # CONFIG_TICK_ONESHOT is not set
> # CONFIG_NO_HZ is not set
> # CONFIG_HIGH_RES_TIMERS is not set
> 
> I will try to turn on those in a few days and see if notice a
> difference.

Essentially the same:

$ cat ./.config | egrep "CONFIG_TICK_ONESHOT|CONFIG_NO_HZ|CONFIG_HIGH_RES_TIMERS"
$ head Makefile 
VERSION = 2
PATCHLEVEL = 6
SUBLEVEL = 22
EXTRAVERSION = -rc5
NAME = Holy Dancing Manatees, Batman!

-- 
	Evgeniy Polyakov
