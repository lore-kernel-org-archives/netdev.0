From: David Miller <davem@davemloft.net>
Subject: Re: Question about NAT-T and PF_KEY...
Date: Fri, 14 Sep 2007 17:36:20 -0700 (PDT)
Message-ID: <20070914.173620.23022708.davem@davemloft.net>
References: <1189369814.19024.28.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ikev2-devel@lists.sourceforge.net
To: sgros@zemris.fer.hr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:35761
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755189AbXIOAgY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2007 20:36:24 -0400
In-Reply-To: <1189369814.19024.28.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stjepan Gros <sgros@zemris.fer.hr>
Date: Sun, 09 Sep 2007 22:30:13 +0200

> I'm having problems telling the kernel to do ESP-in-UDP encapsulation.
> Outgoing direction seems to work, but the incoming packets on the other
> side are passed to ikev2 daemon instead of kernel decapsulating them.

The daemon getting the packets on the UDP socket can only mean that
the rule hasn't been setup correctly.
