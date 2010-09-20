From: David Miller <davem@davemloft.net>
Subject: Re: E1000E/82567LM-3: link reported up too soon
Date: Mon, 20 Sep 2010 15:23:52 -0700 (PDT)
Message-ID: <20100920.152352.193726412.davem@davemloft.net>
References: <87y6awjhxv.fsf@small.ssi.corp>
	<20100920.131839.173838219.davem@davemloft.net>
	<87aancqf3a.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753728Ab0ITWXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 18:23:33 -0400
In-Reply-To: <87aancqf3a.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Mon, 20 Sep 2010 23:28:57 +0200

> I added printk() to see where/if those first packets get dropped in
> e1000e code. I followed those first packets to e1000_xmit_frame() and
> don't see anything obvious happening there, i.e. they are passed to the
> device as expected.

I suspect the packet is sucessfully given to the chip and the PHY simply
doesn't put it onto the wire for whatever reason.
