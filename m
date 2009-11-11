From: Octavian Purdila <opurdila@ixiacom.com>
Subject: Re: [PATCH] [next-next-2.6] net: configurable device name hash
Date: Wed, 11 Nov 2009 21:38:44 +0200
Message-ID: <200911112138.44074.opurdila@ixiacom.com>
References: <200911112116.14103.opurdila@ixiacom.com> <20091111.112120.134023270.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:14981 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758403AbZKKTlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 14:41:42 -0500
In-Reply-To: <20091111.112120.134023270.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 11 November 2009 21:21:20 you wrote:
> From: Octavian Purdila <opurdila@ixiacom.com>
> Date: Wed, 11 Nov 2009 21:16:14 +0200
> 
> > Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> 
> We're not doing this sorry.
> 
> Dynamically size it at boot time or something, but a config
> option is out of the question.
> 

I don't think we can dynamically size it at boot time since it depends on the 
usage pattern which is impossible to determine at boot time, right?

Would it be acceptable to grow it at runtime, in list_netdevice for instance?

