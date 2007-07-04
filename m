From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Tue, 03 Jul 2007 21:59:48 -0400
Message-ID: <1183514388.5174.29.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru>
	 <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
	 <1182275300.4968.83.camel@localhost> <1182989145.5155.81.camel@localhost>
	 <1183411245.6609.16.camel@teletran1> <1183468188.5159.73.camel@localhost>
	 <1183491084.14005.27.camel@teletran1>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:28835 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755215AbXGDB7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 21:59:51 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1958735wxd
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 18:59:51 -0700 (PDT)
In-Reply-To: <1183491084.14005.27.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-03-07 at 12:31 -0700, Matt Carlson wrote:

> I had planned on using netperf, but pktgen sounds like a more controlled
> environment.  Thanks for the tip.

I can help more if you use pktgen - netperf is more involved. Also
pktgen is much closer to the driver so it would let you see closely
if any improvements are obvious or not. 

> Do you see any reason why we couldn't just add the VLAN code to the prep
> stage and simply overwrite that portion of the skb-cb?  Our driver would
> just store its value in the base_flags member of tg3_tx_cbdata.

That would be a much better approach;-> Go for it.

cheers,
jamal


