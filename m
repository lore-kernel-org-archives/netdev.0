From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Mon, 17 Sep 2007 14:27:40 +0400
Message-ID: <20070917102738.GA3087@2ka.mipt.ru>
References: <1189959274.4241.30.camel@localhost> <20070916.123158.92582301.davem@davemloft.net> <1189975284.4230.14.camel@localhost> <1189975939.4230.19.camel@localhost> <1189977000.4230.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, kaber@trash.net, dada1@cosmosbay.com
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:42956 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751069AbXIQK3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Sep 2007 06:29:38 -0400
Content-Disposition: inline
In-Reply-To: <1189977000.4230.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 16, 2007 at 05:10:00PM -0400, jamal (hadi@cyberus.ca) wrote:
> On Sun, 2007-16-09 at 16:52 -0400, jamal wrote:
> 
> > What i should say is
> > if i grabbed the lock explicitly without disabling irqs it wont be much
> > different than what is done today and should always work.
> > No?
> 
> And to be more explicit, heres a patch using the macros from previous
> patch. So far tested on 3 NICs.

How many cpu collisions you are seeing?
Did I understand you right, that you replaced trylock with lock and
thus removed collision handling and got better results?


-- 
	Evgeniy Polyakov
