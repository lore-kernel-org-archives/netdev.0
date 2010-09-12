From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: pskb_expand_head() optimization
Date: Sun, 12 Sep 2010 09:13:53 -0700 (PDT)
Message-ID: <20100912.091353.71112923.davem@davemloft.net>
References: <20100911.203002.193707453.davem@davemloft.net>
	<20100912104534.GA2056@del.dom.local>
	<20100912.085833.226777368.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59918
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752312Ab0ILQNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Sep 2010 12:13:35 -0400
In-Reply-To: <20100912.085833.226777368.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


BTW, Jarek, as to your idea to store a tail pointer in the shinfo, how
will you sync that tail pointer in all of the shinfo instances
referencing the frag list?

It simply can't work, we have to copy.
