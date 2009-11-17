From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] net: device name allocation cleanups
Date: Tue, 17 Nov 2009 09:01:57 -0800
Message-ID: <20091117090157.2a07bed5@nehalam>
References: <200911171849.03870.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35969 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752580AbZKQRCV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 12:02:21 -0500
In-Reply-To: <200911171849.03870.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 18:49:03 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
> ---

You have merged the dev_alloc_name into all the registration paths.
Before it was possible for device to call register_netdevice with a name
with a % in it. Only if it did dev_alloc_name or register_netdev would
the %d be interpreted.

So this patch causes a change which may be visible in user space.

-- 
