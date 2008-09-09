From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 9 Sep 2008 16:21:19 -0300
Message-ID: <20080909192119.GJ12726@ghostprotocols.net>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com> <48C6052D.2080203@redhat.com> <87zlmhs7we.fsf@basil.nowhere.org> <48C6C300.4050102@redhat.com> <20080909190737.GB7714@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Snook <csnook@redhat.com>, Rick Jones <rick.jones2@hp.com>,
	Netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36371 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752483AbYIIT3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 15:29:08 -0400
Content-Disposition: inline
In-Reply-To: <20080909190737.GB7714@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Tue, Sep 09, 2008 at 09:07:37PM +0200, Andi Kleen escreveu:
> > These apps have a love/hate relationship with TCP.  They'll probably love 
> > SCTP 5 years from now, but it's not mature enough for them yet.  They do 
> > want to minimize all latencies, 
> 
> Then they should just TCP_NODELAY.
> 
> > and many of the apps explicitly set 
> > TCP_NODELAY. 
> 
> That's the right thing for them.

But please ask them to use writev or build the logical packet in
userspace, sending it as just one buffer, or they will start asking for
nagle tunables ;-)
 
- Arnaldo
