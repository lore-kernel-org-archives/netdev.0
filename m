From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet: fix compilation with gcc-3.4
Date: Wed, 19 Nov 2008 14:17:54 -0800 (PST)
Message-ID: <20081119.141754.217006788.davem@davemloft.net>
References: <20081117100320.GB10586@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36094
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751262AbYKSWRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 17:17:55 -0500
In-Reply-To: <20081117100320.GB10586@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Mon, 17 Nov 2008 13:03:20 +0300

>   CC [M]  net/phonet/af_phonet.o
> net/phonet/af_phonet.c: In function `pn_socket_create':
> net/phonet/af_phonet.c:38: sorry, unimplemented: inlining failed in call to 'phonet_proto_put': function body not available
> net/phonet/af_phonet.c:99: sorry, unimplemented: called from here
> make[3]: *** [net/phonet/af_phonet.o] Error 1
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Also applied, thanks Alexey.
