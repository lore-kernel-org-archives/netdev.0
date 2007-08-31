From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/1][RFC] add a private field to the sock structure
Date: Thu, 30 Aug 2007 22:40:49 -0700 (PDT)
Message-ID: <20070830.224049.35665219.davem@davemloft.net>
References: <20070829164114.868188182@f002726.toulouse-stg.fr.ibm.com>
	<20070829.112316.98862875.davem@davemloft.net>
	<20070829191831.GA16184@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, netdev@vger.kernel.org, ralf@linux-mips.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57639
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753652AbXHaFku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 01:40:50 -0400
In-Reply-To: <20070829191831.GA16184@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 29 Aug 2007 16:18:31 -0300

> Nah, it still there, sk_protinfo, its just ax25 that uses it
> (nudge(Ralf)). How do we state that a struct field is deprecated and
> will be removed soon(tm)?

You get rid of all the in-tree users and then just kill it :)

More seriously, I don't think we need a deprecation schedule
for a struct member, either it's not used in-tree anymore or
it isn't.  We'll go crazy with any other policy and it's
difficult enough shrinking these things :-)
