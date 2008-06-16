From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: packetloss, on e1000e worse than r8169?
Date: Tue, 17 Jun 2008 00:17:33 +0300
Message-ID: <20080616211411.M35364@visp.net.lb>
References: <20080616193501.M64730@visp.net.lb> <4856C3A7.9070703@cosmosbay.com> <20080616202210.M84100@visp.net.lb> <4856CEDC.6010706@intel.com> <20080616204411.M52834@visp.net.lb> <4856D1D6.7040207@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:43423 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754125AbYFPVRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 17:17:52 -0400
In-Reply-To: <4856D1D6.7040207@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What i notice now, i am not sure if errors updated realtime (maybe with delay,
then my idea is wrong).

Error appearing each 1 or 2 seconds.
If i do watch -n 1 "ifconfig eth1", exactly each _2nd_ cycle (means one is ok,
one errors increased, one is ok, one is errors counter increased), errors is
increasing. Maybe it is some SMI interrupt happening (for example Intel AMT
maybe using card for something)?
Or some routing processing (it is 900 routes there), like garbage collection.
But as i know garbage collector doesn't run each 1-2 second.



--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

