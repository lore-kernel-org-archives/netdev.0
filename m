From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Tue, 19 Jun 2007 20:45:45 +0400
Message-ID: <20070619164544.GC17942@2ka.mipt.ru>
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
Received: from relay.2ka.mipt.ru ([194.85.82.65]:57303 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755740AbXFSQqc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2007 12:46:32 -0400
Content-Disposition: inline
In-Reply-To: <1182270529.4968.73.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 19, 2007 at 12:28:49PM -0400, jamal (hadi@cyberus.ca) wrote:
> In my case, I have:
> # CONFIG_TICK_ONESHOT is not set
> # CONFIG_NO_HZ is not set
> # CONFIG_HIGH_RES_TIMERS is not set

$ cat ./.config | egrep "CONFIG_TICK_ONESHOT|CONFIG_NO_HZ|CONFIG_HIGH_RES_TIMERS"
$

> I will try to turn on those in a few days and see if notice a
> difference.

It is turned off.

> Again, thanks Evgeniy.

No problem.

> cheers,
> jamal

-- 
	Evgeniy Polyakov
