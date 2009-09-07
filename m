From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: multicast routing and multiple interfaces with same IP
Date: Mon, 7 Sep 2009 19:25:16 +0300
Message-ID: <200909071925.17078.opurdila@ixiacom.com>
References: <1b9338490908111626j55b49177q71b8a373b6e6381b@mail.gmail.com> <20090829.000154.263733862.davem@davemloft.net> <1b9338490909070835t3517bc36o396539e7ea1721fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Ilia K." <mail4ilia@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:5625 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753943AbZIGQ1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Sep 2009 12:27:42 -0400
In-Reply-To: <1b9338490909070835t3517bc36o396539e7ea1721fc@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 07 September 2009 18:35:41 you wrote:
> Hi,
> I'm attaching a new patch. The changes:
> mroute.h:
> - consistent name for interface index: vifc_lcl_ifindex
> - union of vifc_lcl_addr and vifc_lcl_ifindex since either one of them
> can be used
> ipmr.c:
> - case VIFF_USE_IFINDEX and case 0 had almost the same code, so using
> fall through and if to eliminate code duplication
> 

Hi Ilia,

Looks good to me, but there are a couple of code style issues reported by 
./scripts/checkpatch.pl. 

Also, here:

>+               } else {                                                                                                                       
>+                       dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr); 
>+               }                                                                                                                              

Usually no braces are used for single line statements in if/else.

tavi



