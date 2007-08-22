From: Gabriel C <nix.or.die@googlemail.com>
Subject: drivers/net/ppp_generic - __modpost error ( Re: 2.6.23-rc3-mm1 )
Date: Wed, 22 Aug 2007 19:10:16 +0200
Message-ID: <46CC6DF8.1090504@googlemail.com>
References: <20070822020648.5ea3a612.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:28575 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765026AbXHVRLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 13:11:40 -0400
Received: by nf-out-0910.google.com with SMTP id g13so171183nfb
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2007 10:11:38 -0700 (PDT)
In-Reply-To: <20070822020648.5ea3a612.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Got it with a randconfig ( http://194.231.229.228/kernel/mm/2.6.23-rc3-mm1/r/randconfig-9 )
( patch from http://lkml.org/lkml/2007/8/22/273 is needed too or CONFIG_SCSI_ADVANSYS need be N)


...

ERROR: "slhc_init" [drivers/net/ppp_generic.ko] undefined!
ERROR: "slhc_remember" [drivers/net/ppp_generic.ko] undefined!
ERROR: "slhc_uncompress" [drivers/net/ppp_generic.ko] undefined!
ERROR: "slhc_free" [drivers/net/ppp_generic.ko] undefined!
ERROR: "slhc_compress" [drivers/net/ppp_generic.ko] undefined!
ERROR: "slhc_toss" [drivers/net/ppp_generic.ko] undefined!
make[1]: *** [__modpost] Error 1
make: *** [modules] Error 2

...


Regards,

Gabriel
