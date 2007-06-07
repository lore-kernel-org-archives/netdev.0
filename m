From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Wed, 06 Jun 2007 21:08:01 -0400
Message-ID: <1181178481.4064.121.camel@localhost>
References: <1181168020.4064.46.camel@localhost>
	 <20070606.153530.48530367.davem@davemloft.net>
	 <1181172766.4064.83.camel@localhost>
	 <20070606.165356.102125635.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, peter.p.waskiewicz.jr@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org, auke-jan.h.kok@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:37430 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756420AbXFGBIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 21:08:05 -0400
Received: by py-out-1112.google.com with SMTP id a29so591464pyi
        for <netdev@vger.kernel.org>; Wed, 06 Jun 2007 18:08:04 -0700 (PDT)
In-Reply-To: <20070606.165356.102125635.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-06-06 at 16:53 -0700, David Miller wrote:

> There are of course other uses for multiple TX queues, and in
> particular my finer-grained locking example.
>
> I'm still amazed the TX locking issue wasn't clear to you,
> too nervous about tonight's game? :)

It's too depressing - so i came back here for a break ;->
I cant even stand Don Cherry today.

As a side note: You will have to do a lot of surgery to the current code
to make tx run on multi CPUs. It needs some experimenting to get right.
And i am begining to like Herberts changes ;->
I am not against multi-rings; iam just suggesting an alternative
approach which is less disruptive.

In regards to the tx lock - my thinking is resolving that via tx
batching. You amortize the lock over multiple packets. There may be
value in fine grained locking - i need to think about it. A small
extension to the batching patches will provide the change i am
proposing.

cheers,
jamal



