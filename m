From: David Miller <davem@davemloft.net>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 18:24:07 -0700 (PDT)
Message-ID: <20100420.182407.174368203.davem@davemloft.net>
References: <20100420.181434.35828504.davem@davemloft.net>
	<20100420.181648.183008607.davem@davemloft.net>
	<Pine.LNX.4.64.1004202120180.29631@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754250Ab0DUBYC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 21:24:02 -0400
In-Reply-To: <Pine.LNX.4.64.1004202120180.29631@hs20-bc2-1.build.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 20 Apr 2010 21:21:36 -0400 (EDT)

> Posting once more. Both LRO and GRO are off. And it is default.

Weird, ok thanks for posting this information.

Maybe whatever sets up your bridge turns off GRO, but that's extremely
unfortunate since the whole point of GRO was so that we could keep it
enabled even with bridging or forwarding enabled.
