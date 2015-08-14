From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux 4.2-rc6 regression: RIP: e030:[<ffffffff8110fb18>]
 [<ffffffff8110fb18>] detach_if_pending+0x18/0x80
Date: Fri, 14 Aug 2015 15:39:25 -0700
Message-ID: <1439591965.7507.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <7c39e6332aae572372108d5fd68c503b@eikelenboom.it>
	 <1439412094.29802.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0de9f30086ee2e662bdafee61d24b3c1@eikelenboom.it>
	 <20150812.144040.1151964094247340464.davem@davemloft.net>
	 <b5e9ffc27531e98bc2ac1e28d6a3d0f0@eikelenboom.it>
	 <1439419279.29802.25.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3b284689aaa1573610c0e388e66e756a@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xen-devel@lists.xen.org,
	david.vrabel@citrix.com
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33970 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbbHNWj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 18:39:27 -0400
In-Reply-To: <3b284689aaa1573610c0e388e66e756a@eikelenboom.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2015-08-15 at 00:09 +0200, Sander Eikelenboom wrote:
> On 2015-08-13 00:41, Eric Dumazet wrote:
> > On Wed, 2015-08-12 at 23:46 +0200, Sander Eikelenboom wrote:
> > 
> >> Thanks for the reminder, but luckily i was aware of that,
> >> seen enough of your replies asking for patches to be resubmitted
> >> against "the other tree" ;)
> >> Kernel with patch is currently running so fingers crossed.
> > 
> > Thanks for testing. I am definitely interested knowing your results.
> 
> Hmm it seems now commit 83fccfc3940c4a2db90fd7e7079f5b465cd8c6af is 
> breaking things
> (have to test if a revert helps) i get this in some guests:


Yes, this was fixed by :
http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=83fccfc3940c4a2db90fd7e7079f5b465cd8c6af
