From: Daniele Venzano <venza@brownhat.org>
Subject: Re: Re: pktgen terminating condition
Date: Fri, 31 Aug 2007 14:17:24 +0200
Message-ID: <1188562644-ab74f9e250635783bce7d5179bcd17eb@brownhat.org>
References: <535ddc6b0708290959j4b89579dk37c97f555f7cfcb9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rick.jones2@hp.com, msb@google.com,
	netdev@vger.kernel.org, grundler@google.com,
	robert.olsson@its.uu.se, jeff@garzik.org, nhorman@tuxdriver.com
To: "Mandeep Baines" <mandeep.baines@gmail.com>, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infomaniak.ch ([84.16.68.89]:34580 "EHLO
	smtp1.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964857AbXHaMiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 08:38:05 -0400
In-Reply-To: <535ddc6b0708290959j4b89579dk37c97f555f7cfcb9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----- Message d'origine -----
De: "Mandeep Baines" <mandeep.baines@gmail.com>
Date: Wed, 29 Aug 2007 09:59:42 -0700
Sujet: Re: pktgen terminating condition

>> Looks good to me given the desire. I would bounce it by whoever the
>> maintainer is - they may have some insights on the lazy tx prune habit.
>>
>
>+ nhorman@tuxdriver.com
>+ jeff@garzik.org
>
>I'll work on a NAPI patch.
Here I'm (the maintainer). Sorry for the delay replying.

I don't regard the TxOK solution as something usable for mainline, but it has its use for the users of pktgen.

NAPI is the way to go.

Thanks, bye.


--
Daniele Venzano
venza@brownhat.org
