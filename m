From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: pull request: wireless-next 2014-08-01
Date: Mon, 4 Aug 2014 22:39:47 -0700
Message-ID: <ED6BF15D-CA1F-4E35-8301-E9A9EEDE3AD6@holtmann.org>
References: <20140801165738.GA26953@tuxdriver.com> <20140802.193939.2179004210212543536.davem@davemloft.net> <C2EB98EF-6873-4F44-B914-A9F89146914A@holtmann.org> <20140804145342.GB16658@tuxdriver.com>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "linux-wireless@vger.kernel.org Wireless"
	<linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53435 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbaHEFje convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 01:39:34 -0400
In-Reply-To: <20140804145342.GB16658@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

>>>> Please pull this last(?) batch of wireless change intended for the
>>>> 3.17 stream...
>>> 
>>> When I pull this I get tons of conflicts for:
>>> 
>>> CONFLICT (content): Merge conflict in net/6lowpan/iphc.c
>>> 
>>> I don't feel comfortable fixing these up, where are they coming
>>> from?
>> 
>> I was short on time yesterday, but now I checked up on this in detail. The merge conflicts are actually simple to resolve. You can just rely on John's tree to have the more recent net/6lowpan/ tree. I should have insisted on merging net/6lowpan/ through bluetooth-next and wireless-next way earlier to avoid conflicts.
>> 
>> In the future we will avoid this by ensuring that all goes via bluetooth-next first. Sorry for this confusion. John mentioned these merge conflicts in his footnote.
>> 
>> John, do you just want to resolve the merge conflicts and send Dave a new pull request?
> 
> I'm happy to do that, if Dave wants.  But as you say, once the initial
> shock of all those conflicts passes the resolution really is fairly
> simple. :-)

do you want John to just do the merge conflict resolution? They are all trivial.

Regards

Marcel
