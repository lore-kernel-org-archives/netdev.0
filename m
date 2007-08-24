From: David Miller <davem@davemloft.net>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Fri, 24 Aug 2007 14:47:11 -0700 (PDT)
Message-ID: <20070824.144711.18301866.davem@davemloft.net>
References: <200708241747.16592.ossthema@de.ibm.com>
	<20070824085203.42f4305c@freepuppy.rosehill.hemminger.net>
	<46CF127D.1090609@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, ossthema@de.ibm.com,
	akepner@sgi.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40841
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760445AbXHXVrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 17:47:12 -0400
In-Reply-To: <46CF127D.1090609@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Fri, 24 Aug 2007 18:16:45 +0100

> Does hardware interrupt mitigation really interact well with NAPI?

It interacts quite excellently.

There was a long saga about this with tg3 and huge SGI numa
systems with large costs for interrupt processing, and the
fix was to do a minimal amount of interrupt mitigation and
this basically cleared up all the problems.

Someone should reference that thread _now_ before this discussion goes
too far and we repeat a lot of information and people like myself have
to stay up all night correcting the misinformation and
misunderstandings that are basically guarenteed for this topic :)
