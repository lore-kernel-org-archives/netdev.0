From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Tue, 19 May 2009 14:21:28 +0300
Message-ID: <200905191421.28519.denys@visp.net.lb>
References: <20090517201528.GA8552@ami.dom.local> <200905191404.50464.denys@visp.net.lb> <20090519111857.GC5521@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, kaber@trash.net, davem@davemloft.net,
	devik@cdi.cz, Eric Dumazet <dada1@cosmosbay.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50154 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619AbZESLVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 07:21:46 -0400
In-Reply-To: <20090519111857.GC5521@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 19 May 2009 14:18:57 Jarek Poplawski wrote:
>
> Sure, if the queue is too short we could have a problem with reaching
> the expected rate; but here it's all backwards - it could actually
> "help" with the stats. ;-)
>
> Jarek P.
Well, i had real experience on HTB, when i set too short buffers on  my QoS 
qdiscs, the incoming rate jumped too high than overall. When i set larger 
buffers (and by the way dropped sfq and use bfifo) - it is dropped.  No idea 
why, bug or specific things in  protocols congestion control. Maybe worth to 
try...

