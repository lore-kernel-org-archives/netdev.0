From: "Eliezer Tamir" <eliezert@broadcom.com>
Subject: Re: [PATCH][BNX2X] round three
Date: Thu, 11 Oct 2007 19:53:39 +0200
Message-ID: <1192125219.29746.143.camel@eliezer>
References: <1192038559.29746.127.camel@eliezer>
 <470D2D7E.8080507@broadcom.com>
 <20071010.175942.55509516.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, mchan@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2879 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755489AbXJKRw3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 13:52:29 -0400
In-Reply-To: <20071010.175942.55509516.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-10-10 at 17:59 -0700, David Miller wrote:

...

> I was going to add this to the tree for 2.6.24 but there is simply
> too much super-ugly stuff in this driver for me to do so.

We will rewrite bnx2x_hsi.h bnx2x_init.h and bnx2x_init_vlaues.h.

Does bnx2x_asm.h look OK?


> Look, there is zero way I'm adding a driver that's written like this
> to the tree.
> 
...

> This huge header file full of register programming magic goes way
> beyond the limits of "reasonable" and has to go.

Will it be OK if we replace it with 4-5 headers so we can maintain them
better manually. (I'm asking what is the upper bound to the number of
header files you would consider reasonable for this driver.)

Thanks
Eliezer


