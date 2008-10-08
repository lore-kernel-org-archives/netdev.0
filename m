From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 10:06:38 +0300
Message-ID: <200810081006.38840.denys@visp.net.lb>
References: <48EB5A92.6010704@trash.net> <48EBFF5E.1090902@trash.net> <20081008065551.GB4174@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	Simon Horman <horms@verge.net.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:45438 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753255AbYJHHIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 03:08:43 -0400
In-Reply-To: <20081008065551.GB4174@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 08 October 2008, Jarek Poplawski wrote:
> On Wed, Oct 08, 2008 at 02:31:26AM +0200, Patrick McHardy wrote:
> ...
>
> > I'm pretty sure that the differences are caused by HTB not being
> > in control of the queue since the device is the real bottleneck
> > in this configuration.
>
> Yes, otherwise there would be no requeuing. And, btw. the golden rule
> of scheduling/shaping is limiting below "hardware" limits.
By the way, HTB counting ethernet headers (e.g. if you send 1500 byte ping, it 
will be 1514 in tc counters) . So possible ethernet overhead counted.


