From: David Miller <davem@davemloft.net>
Subject: Re: [Patch 3/5] Network Drop Monitor: Adding kfree_skb_clean for
 non-drops and modifying end-of-line points for skbs
Date: Wed, 04 Mar 2009 13:06:14 -0800 (PST)
Message-ID: <20090304.130614.127792905.davem@davemloft.net>
References: <20090304135415.GB6392@ghostprotocols.net>
	<20090304141831.GB6139@hmsreliant.think-freely.org>
	<20090304161335.GC6392@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51212
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754677AbZCDVGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 16:06:30 -0500
In-Reply-To: <20090304161335.GC6392@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 4 Mar 2009 13:13:35 -0300

> I wouldn't mind the churn, as I really think drop_skb() would be
> clearer, but then this is up to Dave.

I mind the churn, I have to apply this thing and deal with
the merge conflicts :-)

Why not come up with a clever alternative name for kfree_skb_clean()?
