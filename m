From: Bryan Wu <bryan.wu@analog.com>
Subject: Re: Blackfin Ethernet MAC driver compile error
Date: Thu, 04 Oct 2007 17:12:21 +0800
Message-ID: <1191489141.6139.1.camel@roc-laptop>
References: <a425f86c0710020430o3507eeb2veb104dc936f230dd@mail.gmail.com>
Reply-To: bryan.wu@analog.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bryan.wu@analog.com
To: Kalle Pokki <kalle.pokki@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail11.analog.com ([137.71.25.57]:6636 "EHLO
	nwd2mail11.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754254AbXJDJM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2007 05:12:26 -0400
In-Reply-To: <a425f86c0710020430o3507eeb2veb104dc936f230dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-10-02 at 19:30 +0800, Kalle Pokki wrote:
> The Blackfin Ethernet MAC driver does not compile. It seems the driver
> is 
> missing some pinmux defines.
> 
>   CC      drivers/net/bfin_mac.o 
> drivers/net/bfin_mac.c: In function 'setup_pin_mux': 
> drivers/net/bfin_mac.c:275: error: 'P_MII0' undeclared (first use in 
> this function) 
> drivers/net/bfin_mac.c:275: error: (Each undeclared identifier is 
> reported only once 
> drivers/net/bfin_mac.c:275: error: for each function it appears in.) 
> drivers/net/bfin_mac.c:279: error: implicit declaration of function 
> 'peripheral_request_list' 
> drivers/net/bfin_mac.c:285: error: implicit declaration of function 
> 'peripheral_free_list' 
> make[2]: *** [drivers/net/bfin_mac.o] Error 1 
> make[1]: *** [drivers/net] Error 2 
> make: *** [drivers] Error 2
> 
Sorry for missing the pinmux patches.
After Linus's git-pull, it should be fixed in the latest Linus mainline
git tree.
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=66b1f1a982bf4dbad9fa0de25b8d95c4936f05c4

Thanks a lot
-Bryan
