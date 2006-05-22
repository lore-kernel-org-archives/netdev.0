From: Beschorner Daniel <Daniel.Beschorner@facton.com>
Subject: Re: skge driver oops
Date: Mon, 22 May 2006 20:38:51 +0200
Message-ID: <BB1F4EFD574E9F409035BDA71C9612500241A2@exchange.i-bn>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
	"'Stephen Hemminger'" <shemminger@osdl.org>,
	"'david@mantara.com'" <david@mantara.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:64692 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S1751007AbWEVSjE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 May 2006 14:39:04 -0400
To: "'Krzysztof Oledzki'" <olel@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for the hint, Krzysztof!

But this switch doesn't help, the problem for the crash is in my case the rx
side.
I can send big files over the card, as soon as I start receiving the box
crashes with the oopses you can find in former postings.

Daniel


> On Wed, 17 May 2006, Beschorner Daniel wrote:

>> As David and me are using SMP systems when it's crashing, should I give a
>> non-SMP kernel a try, to see if it's some kind of race conditon?

> You may also try this, where ethX is your skge driven ethernet device:
>   /usr/sbin/ethtool -K ethX tx off

>This solved my simmilar problem.

> Best regards,

> 			Krzysztof Oledzki
