From: jamal <hadi@cyberus.ca>
Subject: Re: pktgen terminating condition
Date: Fri, 31 Aug 2007 09:46:31 -0400
Message-ID: <1188567991.4302.17.camel@localhost>
References: <1188395183.4274.19.camel@localhost>
	 <18133.40847.166882.838333@robur.slu.se>
	 <1188475721.22423.35.camel@localhost>
	 <20070830.221909.28790079.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, mandeep.baines@gmail.com,
	rick.jones2@hp.com, msb@google.com, netdev@vger.kernel.org,
	grundler@google.com, robert.olsson@its.uu.se, venza@brownhat.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.188]:4481 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965047AbXHaNqi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 09:46:38 -0400
Received: by rv-out-0910.google.com with SMTP id k20so422742rvb
        for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 06:46:37 -0700 (PDT)
In-Reply-To: <20070830.221909.28790079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-30-08 at 22:19 -0700, David Miller wrote:

> You could implement this quite simply using skb->destructor.

Thats what i was thinking ..

> It will add some atomics, so on weaker pktgen source systems
> it might decrease the generators rate.

Indeed. So maybe a config option instead; it has value afaics in the
batching case only. Need to experiment.

cheers,
jamal


