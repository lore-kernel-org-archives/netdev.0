From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [patch 0/1][RFC] add a private field to the sock structure
Date: Fri, 31 Aug 2007 08:26:20 -0300
Message-ID: <20070831112620.GA2532@ghostprotocols.net>
References: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com> <20070829.112316.98862875.davem@davemloft.net> <20070829191831.GA16184@ghostprotocols.net> <20070830.224049.35665219.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org, ralf@linux-mips.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.225]:49446 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955AbXHaL0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 07:26:30 -0400
Received: by wr-out-0506.google.com with SMTP id 36so535801wra
        for <netdev@vger.kernel.org>; Fri, 31 Aug 2007 04:26:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20070830.224049.35665219.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Thu, Aug 30, 2007 at 10:40:49PM -0700, David Miller escreveu:
> From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
> Date: Wed, 29 Aug 2007 16:18:31 -0300
> 
> > Nah, it still there, sk_protinfo, its just ax25 that uses it
> > (nudge(Ralf)). How do we state that a struct field is deprecated and
> > will be removed soon(tm)?
> 
> You get rid of all the in-tree users and then just kill it :)
> 
> More seriously, I don't think we need a deprecation schedule
> for a struct member, either it's not used in-tree anymore or
> it isn't.  We'll go crazy with any other policy and it's
> difficult enough shrinking these things :-)

OK, I think its enough to say to dlezcano that he should avoid using
sk_protinfo, as soon as we do the work on AX.25 sk_protinfo will be
removed.

- Arnaldo
