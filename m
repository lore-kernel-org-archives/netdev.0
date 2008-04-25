From: David Miller <davem@davemloft.net>
Subject: Re: Socket buffer sizes with autotuning
Date: Thu, 24 Apr 2008 23:36:43 -0700 (PDT)
Message-ID: <20080424.233643.250240829.davem@davemloft.net>
References: <20080422.205945.229828014.davem@davemloft.net>
	<87ej8uyjvv.fsf@basil.nowhere.org>
	<65634d660804242234w66455bedve44801a98e3de9d9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, johnwheffner@gmail.com, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54287
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756319AbYDYGgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2008 02:36:43 -0400
In-Reply-To: <65634d660804242234w66455bedve44801a98e3de9d9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Tom Herbert" <therbert@google.com>
Date: Thu, 24 Apr 2008 22:34:50 -0700

> Queuing in the host as opposed to in the TX NIC might be beneficial to make
> work conserving queuing disciplines more effective, since once a packet is
> queued in the NIC the host can no longer perform any more scheduling on
> it.    In fact, we have been working on a mechanism to dynamically limit
> queuing in the NIC (by number of bytes), so that more packets will be queued
> in host.  This seems to give better results with some of the qdiscs (I can
> post a patch if there's interest in this).

This work is interesting, but doesn't it make more sense to limit by
number of packets instead of bytes?

No intermediate node that I know of drops bytes, they drop packets
instead :-)
