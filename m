From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] net: Toeplitz library functions
Date: Tue, 24 Sep 2013 09:14:59 -0700
Message-ID: <1380039299.3165.91.camel@edumazet-glaptop>
References: <alpine.DEB.2.02.1309231535030.23896@tomh.mtv.corp.google.com>
	 <1379980991.3165.37.camel@edumazet-glaptop>
	 <20130924023038.GA22393@order.stressinduktion.org>
	 <20130924033505.GB22393@order.stressinduktion.org>
	 <1380001118.3165.41.camel@edumazet-glaptop>
	 <20130924160145.GB26769@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:64809 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab3IXQPC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 12:15:02 -0400
Received: by mail-pa0-f48.google.com with SMTP id bj1so3861741pad.7
        for <netdev@vger.kernel.org>; Tue, 24 Sep 2013 09:15:01 -0700 (PDT)
In-Reply-To: <20130924160145.GB26769@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-24 at 18:01 +0200, Hannes Frederic Sowa wrote:

> inet(6)_ehashfn does get used by udp btw. But I do not understand the code,
> yet. ;)

Oh well, thats the SO_REUSEPORT thing. We do not really care, thats only
used to try to steer udp flows on a given socket, but its a hint.

Presumably it should use a separate secret key.
