From: David Miller <davem@davemloft.net>
Subject: Re: SFQ qdisc crashes with limit of 2 packets
Date: Sun, 30 Sep 2007 17:51:44 -0700 (PDT)
Message-ID: <20070930.175144.126789473.davem@davemloft.net>
References: <20070919094803.GA17740@ms2.inr.ac.ru>
	<46F11F46.8060108@trash.net>
	<20070921155522.GA6755@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, cebbert@redhat.com, netdev@vger.kernel.org
To: kuznet@ms2.inr.ac.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48743
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750904AbXJAAvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Sep 2007 20:51:44 -0400
In-Reply-To: <20070921155522.GA6755@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Date: Fri, 21 Sep 2007 19:55:22 +0400

> Hello!
> 
> Remove artificial limitation for sfq queue limit.
> 
> This is followup to Patrick's patch. A little optimization to enqueue
> routine allows to remove artificial limitation on queue length.
> 
> Plus, testing showed that hash function used by SFQ is too bad or even worse.
> It does not even sweep the whole range of hash values.
> Switched to Jenkins' hash.
> 
> 
> Signed-off-by: Alexey Kuznetsov <kaber@ms2.inr.ac.ru>

Applied, thanks Alexey.
