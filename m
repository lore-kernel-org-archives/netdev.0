From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [GIT]: Networking
Date: Wed, 20 Aug 2008 06:20:13 +0200
Message-ID: <1219206013.7591.227.camel@violet.holtmann.net>
References: <20080819.140458.236030589.davem@davemloft.net>
	 <200808192315.48718.rjw@sisk.pl>
	 <alpine.LFD.1.10.0808191425050.3324@nehalem.linux-foundation.org>
	 <20080819.143556.245692295.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, rjw@sisk.pl,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:35057 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783AbYHTEUL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 00:20:11 -0400
In-Reply-To: <20080819.143556.245692295.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi guys,

> And then there is the Bluetooth SCO change which I agree was
> borderline and I should have pushed back on.

so this is the statement, I sent Dave to explain why that change was in
there:

---
For the btusb driver this adds the promised SCO support. The btusb
driver is a new driver and will eventually replace hci_usb. Adding SCO
support was the last missing piece. All distributions are using the
hci_usb driver at the moment and you can only select one of them. So
this can't introduce any regression. With this change the distributions
are now able to select the new driver if they really want to.
---

Was this absolutely needed after -rc3. Of course not. No questions asked
about it. So why did it ended up in there?

Almost everybody is using the hci_usb driver and that one has issues
that are beyond fixable. So the btusb is its replacement and with this
change it became a real alternate solution. For me this is a new driver
that would allow people to use it in case hci_usb gives them a hard time
and falls over again. And fixing hci_usb is not an option. A lot of
people tried it and they failed. I think the last one was Pavel a month
ago. This is why I re-wrote the whole beast from scratch.

So that is my excuse why I thought this would be good choice to push it
to Dave. No more excuses and no new drivers after the merge window. At
least not from me.

Regards

Marcel


