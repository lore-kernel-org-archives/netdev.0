From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: bnx2/5709: Strange interrupts spread
Date: Mon, 19 Jul 2010 11:47:11 -0700
Message-ID: <1279565231.20559.14.camel@HP1>
References: <AANLkTiniNNPV9ztxXHtX4np7PIZabkm0I4v5O29chf8i@mail.gmail.com>
 <AANLkTikfEED5Hvt80G6EnMwPBByMuw4r1Xg2ITjuZ0eV@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Christophe Ngo Van Duc" <cngovanduc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2286 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S936486Ab0GSSsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jul 2010 14:48:15 -0400
In-Reply-To: <AANLkTikfEED5Hvt80G6EnMwPBByMuw4r1Xg2ITjuZ0eV@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 2010-07-19 at 08:55 -0700, Christophe Ngo Van Duc wrote:
> So i've been able to do some test today:
> If I put the 2 interface in a bridge with no IP adress, the interrupts
> are on 1 CPU
> If I put the 2 interface in a bridge with IP adress, the interrupts
> are still on 1 CPU
> If I put the 2 interface outside the bridge with IP address,
> everything works fine the interrupts get spread on the CPU
> 
> So the conclusion seems to be that when the bnx2 is put into
> promiscuous mode by the bridge, the RSS hash stop to work even if
> traffic is IP in nature.

I did a quick test with bridging and saw no problem with RSS.  I did see
this though:

br0 received packet on queue 4, but number of RX queues is 1

Looks like it is a warning message from RPS.


