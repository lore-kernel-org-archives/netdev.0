From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 4.2-rc6 regression: RIP: e030:[<ffffffff8110fb18>]
 [<ffffffff8110fb18>] detach_if_pending+0x18/0x80
Date: Mon, 17 Aug 2015 07:21:47 -0700
Message-ID: <1439821307.7258.20.camel@edumazet-glaptop2.roam.corp.google.com>
References: <7c39e6332aae572372108d5fd68c503b@eikelenboom.it>
	 <1439412094.29802.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0de9f30086ee2e662bdafee61d24b3c1@eikelenboom.it>
	 <20150812.144040.1151964094247340464.davem@davemloft.net>
	 <b5e9ffc27531e98bc2ac1e28d6a3d0f0@eikelenboom.it>
	 <1439419279.29802.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3b284689aaa1573610c0e388e66e756a@eikelenboom.it>
	 <1439591965.7507.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <963062024.20150817110956@eikelenboom.it>
	 <1439818633.7258.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <196897465.20150817154802@eikelenboom.it> <55D1E97B.6090309@jons.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sander Eikelenboom <linux@eikelenboom.it>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	xen-devel@lists.xen.org, david.vrabel@citrix.com
To: Jon Christopherson <jon@jons.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34914 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751308AbbHQOVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 10:21:52 -0400
In-Reply-To: <55D1E97B.6090309@jons.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-08-17 at 09:02 -0500, Jon Christopherson wrote:
> This is very similar to the behavior I am seeing in this bug:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=102911

OK, but have you applied the fix ?

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=83fccfc3940c4a2db90fd7e7079f5b465cd8c6af

It will be part of net iteration from David Miller to Linus Torvald.
