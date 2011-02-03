From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 3 Feb 2011 23:55:54 +0100
Message-ID: <20110203225554.GA3227@nuttenaction>
References: <20110202.170750.229739784.davem@davemloft.net>
 <47859e9273bb0c1b2c32fc1adfa450ee@localhost>
 <AANLkTimWHAz0SX_u42guHp2KNyQESsH6ysNwRoe7ZVJ=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	dccp@vger.kernel.org, therbert@google.com
To: "H.K. Jerry Chu" <hkjerry.chu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:45320 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751200Ab1BCWz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 17:55:57 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTimWHAz0SX_u42guHp2KNyQESsH6ysNwRoe7ZVJ=@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* H.K. Jerry Chu | 2011-02-03 13:17:19 [-0800]:

>> to setup a ns-2 environment but due to lack of time I am a little bit
>> behind schedule. Anyway, why not make this a tunable per route knob so that
>> it is easier to fix things, e.g. set IW back to 3.
>
>You've seemed to get this backwards. Shouldn't we set the default for the normal
>cases and leave the corner cases to the initcwnd and initrwnd knobs to cover?

Yes Jerry, I phrase this a little bit abstruse. Apply David patch and use per
route options to reduce the IW if some curious behavior appear.

It seems the time is come to increase the IW. ;-)

Hagen


