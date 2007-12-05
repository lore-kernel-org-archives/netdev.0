From: David Miller <davem@davemloft.net>
Subject: Re: namespace support requires network modules to say "GPL"
Date: Tue, 04 Dec 2007 22:14:47 -0800 (PST)
Message-ID: <20071204.221447.158735674.davem@davemloft.net>
References: <m163zexrqi.fsf@ebiederm.dsl.xmission.com>
	<4755A025.8090903@candelatech.com>
	<m1odd6w9p6.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, daniel.lezcano@free.fr,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	containers@lists.osdl.org, lkml@rtr.ca,
	shemminger@linux-foundation.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57973
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751791AbXLEGOs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2007 01:14:48 -0500
In-Reply-To: <m1odd6w9p6.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 04 Dec 2007 12:17:57 -0700

> Ben Greear <greearb@candelatech.com> writes:
> 
> > If I *do* need to add some sort of namespace
> > awareness to just achieve today's functionality, I don't mind making the
> > changes,
> > so long as I don't need to change to GPL licensing.  Perhaps at the least you
> > can export enough symbols w/out GPL tag to achieve backwards compat with .23
> > and previous kernels, or rework dev_get_by_* etc to not need GPL'd namespace
> > symbols and just return the device in the default namespace?
> 
> IANAL but to me your code sounds like a derivative work of the linux
> kernel.  Which implies that if you are distributing your module you
> need to change to GPL licensing.  The _GPL tag on EXPORT_SYMBOL does
> not change those rules.

Eric, YANAL and you are also full of hot air.  You are really
testing my patience on this issue.

You fail to ever describe on what factual basis you are making
these claims.  And the reason is that you have ZERO factual basis
for your claims.

Here are the facts:

1) Never, ever, have the function for looking up network devices been
   classified as GPL-only symbols.

   They provide a device based upon a lookup key.

2) You in no way have changed what those functions do in any way
   whatsoever.  They still provide a reference to a network device
   based upon a given lookup key.

   The functions are still doing the same thing they always have.

Therefore, you have decided to uniliaterally change the licensing of
these functions based solely upon your opinion, and not because of
some real change you've made to the code in question.

You have no right to do this.

This is unreasonable, and you must fix this immediately.

And I do mean now, not after you've written several more excessively
long diatribes about how you feel in this matter.

Thank you.
