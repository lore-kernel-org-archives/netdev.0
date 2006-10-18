From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Ethernet Cheap Cryptography
Date: Tue, 17 Oct 2006 20:25:44 -0700 (PDT)
Message-ID: <20061017.202544.74747614.davem@davemloft.net>
References: <200610151820.22867.dpc@asn.pl>
	<17717.40394.531846.695392@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dpc@asn.pl, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46276
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932066AbWJRDZj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 23:25:39 -0400
To: stephen@dino.dnsalias.com
In-Reply-To: <17717.40394.531846.695392@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: stephen@dino.dnsalias.com (Stephen J. Bevan)
Date: Tue, 17 Oct 2006 20:21:46 -0700

> * You write "frames will be delivered in order, so on the other side
>   IV can be always in sync."

In fact, in addition to your comments, Linux can reorder packets
locally within the system even within traffic for the same link.

Any technology which absolutely requires in order packet delivery
isn't going to work very well.
