From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH|[NET]: migrate HARD_TX_LOCK to header file
Date: Sun, 16 Sep 2007 16:28:41 -0400
Message-ID: <1189974522.4230.3.camel@localhost>
References: <1189957725.4241.4.camel@localhost>
	 <20070916.122842.59467739.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:61735 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbXIPU2r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 16:28:47 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1177911wxd
        for <netdev@vger.kernel.org>; Sun, 16 Sep 2007 13:28:46 -0700 (PDT)
In-Reply-To: <20070916.122842.59467739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-16-09 at 12:28 -0700, David Miller wrote:

> The only reason the cpu argument is superfluous is because
> we don't provide a way to pass it on down to netif_tx_lock().
> 
> So instead netif_tx_lock() recomputes that value in this case which is
> extra unnecessary work.
> 
> I would instead suggest ..

sounds much better - will resend after a simple test.

cheers,
jamal

