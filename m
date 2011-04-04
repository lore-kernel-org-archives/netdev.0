From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Allow no-cache copy from user on transmit
Date: Mon, 04 Apr 2011 13:05:38 -0700 (PDT)
Message-ID: <20110404.130538.25131618.davem@davemloft.net>
References: <BANLkTik__2JSNHXf4JBDqQPgDmMgsT9Lug@mail.gmail.com>
	<20110404.095207.137846978.davem@davemloft.net>
	<BANLkTik=hsDPjLUx+evW698moouj5A35jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49953
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755454Ab1DDUGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 16:06:15 -0400
In-Reply-To: <BANLkTik=hsDPjLUx+evW698moouj5A35jw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Mon, 4 Apr 2011 12:44:08 -0700

> I'll take them out, but that will result in one needless conditional
> in the transmit path for architectures that don't support the no cache
> copy, which seems to be everything except x86!?

I think this is a small price to pay for the build regression
exposure, and perheps it's also a bit of an incentive for more
architectures to support nocache copies :-)
