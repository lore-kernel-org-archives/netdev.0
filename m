From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 11:14:50 -0400
Message-ID: <1181574890.4077.41.camel@localhost>
References: <D0122E209EBF8D4CAB38EC6A8AF244E502AB28BA@hasmsx412.ger.corp.intel.com>
	 <1181573285.4077.22.camel@localhost>
	 <1ba2fa240706110800m643da3fam849805189c0540c9@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Cohen, Guy" <guy.cohen@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:28882 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751472AbXFKPOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 11:14:53 -0400
Received: by wr-out-0506.google.com with SMTP id 76so1024141wra
        for <netdev@vger.kernel.org>; Mon, 11 Jun 2007 08:14:52 -0700 (PDT)
In-Reply-To: <1ba2fa240706110800m643da3fam849805189c0540c9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-11-06 at 18:00 +0300, Tomas Winkler wrote:
> On 6/11/07, jamal <hadi@cyberus.ca> wrote:
> > On Mon, 2007-11-06 at 17:30 +0300, Cohen, Guy wrote:
> >
> > >
> > > For WiFi devices the HW often implements the scheduling, especially when
> > > QoS (WMM/11e/11n) is implemented. There are few traffic queues defined
> > > by the specs and the selection of the next queue to transmit a packet
> > > from, is determined in real time, just when there is a tx opportunity.
> > > This cannot be predicted in advance since it depends on the medium usage
> > > of other stations.
> >
> > WMM is a strict prio mechanism.
> > The parametrization very much favors the high prio packets when the
> > tx opportunity to send shows up.
> >
> 
> This is not true, there is no simple priority order from 1 to 4 ,
> rather set of parameters that dermises access to medium.  You have to
> emulate medium behavior to schedule packets in correct order. That's
> why this pushed to HW, otherwise nobody would invest money in this
> part of silicon :)
> 

I dont have the specs neither am i arguing the value of having the
scheduler in hardware. (I think the over radio contention clearly
needs the scheduler in hardware).

But i have read a couple of papers on people simulating this in s/ware.
And have seen people describe the parametrization that is default,
example Slide 43 on:
http://madwifi.org/attachment/wiki/ChipsetFeatures/WMM/qos11e.pdf?format=raw
seems to indicate the default parameters for the different timers
is clearly strictly in favor of you if you have higher prio.
If the info quoted is correct, it doesnt change anything i have said so
far.
i.e it is strict prio scheduling with some statistical chance a low prio
packet will make it. 

cheers,
jamal

