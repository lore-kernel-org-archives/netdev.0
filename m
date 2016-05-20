From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH v9 net-next 4/7] openvswitch: add layer 3 flow/port
 support
Date: Fri, 20 May 2016 17:16:13 +0900
Message-ID: <20160520081611.GB17561@vergenet.net>
References: <1462347393-22354-1-git-send-email-simon.horman@netronome.com>
 <1462347393-22354-5-git-send-email-simon.horman@netronome.com>
 <20160517163250.7ead555e@griffin>
 <20160520052858.GA15505@vergenet.net>
 <20160520100028.0065a2ef@griffin>
 <20160520081120.GA17561@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
	Lorand Jakab <lojakab@cisco.com>,
	Thomas Morin <thomas.morin@orange.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35782 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239AbcETIQX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 04:16:23 -0400
Received: by mail-pa0-f44.google.com with SMTP id tb2so20373387pac.2
        for <netdev@vger.kernel.org>; Fri, 20 May 2016 01:16:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160520081120.GA17561@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 20, 2016 at 05:11:23PM +0900, Simon Horman wrote:
> On Fri, May 20, 2016 at 10:00:28AM +0200, Jiri Benc wrote:
> > On Fri, 20 May 2016 14:29:01 +0900, Simon Horman wrote:
> > > The second option does seem rather tempting although I'm not sure
> > > that it actually plays out in the access-port scenario at this time.
> > 
> > We support gre ports to be access ports currently. With conversion to
> > ipgre, this needs to continue working. It's no problem for frames with
> > the Ethernet header but now we have a situation where a port is tagged,
> > thus the user expects that packets received on that port will behave
> > accordingly. I don't think we can make some packets honor this and some
> > ignore this; and we can't disallow gre to be an access port.
> > 
> > How do you plan to solve this? By user space always pushing an ethernet
> > header before push_vlan?
> 
> Yes. That is my understanding of how OvS currently handles access ports but
> I have a feeling that either I am mistaken or that you are referring to a
> slightly different scenario.

Hi again.

I apologise for having sent my previous email a little too quickly.

My understanding is that currently OvS handles access ports using a
push_vlan action. And that this patch set in conjunction with its
user-space counterpart should ensure that a push_eth action occurs first.
This is the context of my remarks above.
