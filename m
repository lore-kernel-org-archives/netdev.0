From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Problem with patch "make nlmsg_end() and genlmsg_end() void"
Date: Sun, 18 Jan 2015 18:10:46 -0800
Message-ID: <01A82AB9-6ABD-4AD0-9CBC-628091569DB0@holtmann.org>
References: <0397034D-1DF4-409F-B335-FCD0D7EAB940@holtmann.org> <E586D25A-9DAF-4535-A282-120F0C6EAE19@holtmann.org> <CAE4R7bCWSM+SyDR830N1GmukyaMYE_DT0fd4L_x6Py5PEqMe_A@mail.gmail.com>
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Network Development <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Gundersen <teg@jklm.no>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:51979 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbbASCKx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 21:10:53 -0500
In-Reply-To: <CAE4R7bCWSM+SyDR830N1GmukyaMYE_DT0fd4L_x6Py5PEqMe_A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Scott,

> This patch needs to be reverted ASAP.  git bisect landed me here also;
> my processes are getting the OOM msgs.  What testing was done?
> 
> Seems someone does care that nlmsg_end() returns skb->len.

I still wonder how this affects userspace. I have not figured that out. Something goes wrong pretty badly somewhere.

Have you tried the small diff with the two locations that were problematic for me?

Regards

Marcel
