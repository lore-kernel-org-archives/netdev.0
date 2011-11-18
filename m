From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [PATCH net-next] sky2: fix hang in napi_disable
Date: Thu, 17 Nov 2011 18:10:49 -0800 (PST)
Message-ID: <f582e628-7770-43c5-aa90-51cf74141462@tahiti.vyatta.com>
References: <20111117.205234.394141688162787655.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: svenjoac@gmx.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52349 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752751Ab1KRCKu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 21:10:50 -0500
In-Reply-To: <20111117.205234.394141688162787655.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Thu, 17 Nov 2011 16:37:35 -0800
> 
> > If IRQ was never initialized, then calling napi_disable() would
> > hang.
> > Add more bookkeeping to track whether IRQ was ever initialized.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Stephen, your other 6 patches went into 'net' so you have to target
> these fixes there too.
> 

Do you need me to respin them?
