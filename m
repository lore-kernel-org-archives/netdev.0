From: David Miller <davem@davemloft.net>
Subject: Re: [TCP] window reduction fix
Date: Wed, 05 Jul 2006 20:50:31 -0700 (PDT)
Message-ID: <20060705.205031.85393581.davem@davemloft.net>
References: <8dd26e70607050924q48954801h8fd4c32efa37929@mail.gmail.com>
	<44AC1043.10603@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: angelo.castellani@gmail.com, netdev@vger.kernel.org,
	vacirca@infocom.uniroma1.it, andrea.baiocchi@uniroma1.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:64450
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965156AbWGFDuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jul 2006 23:50:06 -0400
To: jheffner@psc.edu
In-Reply-To: <44AC1043.10603@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Wed, 05 Jul 2006 15:17:23 -0400

> Hm, wouldn't that violate the TCP spec?

Yes, this cannot be right.  One cannot shrink the offered
window under any circumstance.

If we over-advertised the window, that isn't something we
can "clean up" like this.
