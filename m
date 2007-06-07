From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Thu, 07 Jun 2007 07:43:49 -0400
Message-ID: <1181216629.4064.22.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:47452 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbXFGLnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 07:43:53 -0400
Received: by py-out-1112.google.com with SMTP id a29so792126pyi
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2007 04:43:52 -0700 (PDT)
In-Reply-To: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-07-06 at 11:46 +0530, Krishna Kumar2 wrote:
> My somewhat confusing netperf script (to run on client) is attached below.
> Server just requires
> to run netserver. Client is not completely accurate since I am not using
> netperf4 (moving to
> that after some initial hiccups).

Thanks KK.
Folks, we need help. Please run this on different hardware. Evgeniy, i
thought this kind of stuff excites you, no? ;-> (wink, wink).
Only the sender needs the patch but the receiver must be a more powerful
machine (so that it is not the bottleneck).
A very interesting test will be say 10K flows serving different packet
sizes to simulate a busy server.

I realized i cant really run the sort of tests KK is running because i
dont have the second machine. With pktgen i have an easy way out because
i can drop all the packets on the receiver and just count them (whereas
netperf requires end 2 end semantics).

cheers,
jamal

