From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] LSM: Add security_socket_post_accept() and
 security_socket_post_recv_datagram().
Date: Tue, 21 Apr 2009 22:07:35 -0700 (PDT)
Message-ID: <20090421.220735.118831531.davem@davemloft.net>
References: <200904220149.n3M1ngLa059958@www262.sakura.ne.jp>
	<20090421.212259.213941533.davem@davemloft.net>
	<200904220502.n3M52GQj001957@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, linux-security-module@vger.kernel.org,
	netdev@vger.kernel.org
To: penguin-kernel@i-love.sakura.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33120
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751382AbZDVFHn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Apr 2009 01:07:43 -0400
In-Reply-To: <200904220502.n3M52GQj001957@www262.sakura.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Date: Wed, 22 Apr 2009 14:02:16 +0900

> Did I miss something?

Do me a favor.  We have mechanisms by which you can queue up packets
(even into userspace) to make policy decisions.

You can make your decision there, and if appropriate, reinject the
packet back into the kernel input processing.

This is how netfilter ip_queue allows people to implement policies
in userspace, and you could use it in the kernel and then need
none of these ugly hooks.
