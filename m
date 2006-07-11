From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Netchannel: default, find, add to socket
Date: Tue, 11 Jul 2006 00:37:35 -0700 (PDT)
Message-ID: <20060711.003735.127203302.davem@davemloft.net>
References: <200607111539.25458.kelly@au.ibm.com>
	<20060711055708.GA3935@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kelly@au1.ibm.com, netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:44972
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030418AbWGKHgx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 03:36:53 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060711055708.GA3935@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 11 Jul 2006 09:57:08 +0400

> Did you benchmarked such approach both with
> and without netchannel bound to the socket?

It is not meant to be used in "real life" :-)
So benchmark is quite useless.

We are starting simple, and eventually all types of packets will hit
some kind of channel, thus making the default channel a kind of
anomaly slow path.

That code will not come immediately, therefore it would be nice
if the performance were not too bad, and it can be made into a
software interrupt or tasklet with some care.
