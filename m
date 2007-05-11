From: jamal <hadi@cyberus.ca>
Subject: RE: [RFC] make qdisc_restart more readable
Date: Fri, 11 May 2007 14:04:31 -0400
Message-ID: <1178906671.4126.2.camel@localhost>
References: <D5C1322C3E673F459512FB59E0DDC32902D42246@orsmsx414.amr.corp.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.237]:29990 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762864AbXEKSEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2007 14:04:34 -0400
Received: by wx-out-0506.google.com with SMTP id h31so950349wxd
        for <netdev@vger.kernel.org>; Fri, 11 May 2007 11:04:34 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32902D42246@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-11-05 at 08:56 -0700, Waskiewicz Jr, Peter P wrote:

> In qdisc_restart(), you removed any check for if
> (!netif_queue_stopped(dev)) before calling dev_hard_start_xmit().  If
> the underlying queue is stopped and you send the skb, you'll generate a
> requeue.  Is there a reason it was removed?
> 

No - its a bug ;-> 
Thanks for staring at this Peter. I will fix it.

cheers,
jamal

