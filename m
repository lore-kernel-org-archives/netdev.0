From: David Miller <davem@davemloft.net>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 06 Mar 2007 13:35:16 -0800 (PST)
Message-ID: <20070306.133516.104036428.davem@davemloft.net>
References: <45EDD17F.5000203@cosmosbay.com>
	<45EDD791.4040908@symas.com>
	<45EDDC4F.7010201@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hyc@symas.com, dada1@cosmosbay.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43572
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1030206AbXCFVfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2007 16:35:20 -0500
In-Reply-To: <45EDDC4F.7010201@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 06 Mar 2007 13:25:35 -0800

> > On the other hand, being able to configure a small MSL for the loopback 
> > device is perfectly safe. Being able to configure a small MSL for other 
> > interfaces may be safe, depending on the rest of the network layout.
> 
> A peanut gallery question - I seem to recall prior discussions about how 
> one cannot assume that a packet destined for a given IP address will 
> remain detined for that given IP address as it could go through a module 
> that will rewrite headers etc.

That's right, both netfilter and the packet scheduler actions
can do that, that's why this whole idea about changing the MSL
on loopback by default is wrong and pointless.
