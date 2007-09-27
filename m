From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Thu, 27 Sep 2007 08:52:03 -0400
Message-ID: <1190897523.4290.29.camel@localhost>
References: <20070927073446.GA14643@gondor.apana.org.au>
	 <20070927092512.GD29329@2ka.mipt.ru>
	 <20070927093358.GA15357@gondor.apana.org.au>
	 <20070927100753.GA22323@2ka.mipt.ru>
	 <20070927102916.GA15749@gondor.apana.org.au>
	 <20070927124120.GA8897@2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:34571 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbXI0MwI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2007 08:52:08 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2102440wxd
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2007 05:52:07 -0700 (PDT)
In-Reply-To: <20070927124120.GA8897@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-27-09 at 16:41 +0400, Evgeniy Polyakov wrote:

> I've attached simple patch which moves checksum helpers out of
> CONFIG_NETFILTER option but still in the same linux/netfilter.h header.
> This should be enough for removing 'select NETFILTER' in your patch.

Is there any point in keeping the code inside netfilter or keeping
the nf_ prefix? something in net/utilities/ or net/core maybe?
the nf_* can still exist in netfilter as aliases to wherever this is
moved to.

cheers,
jamal



