From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [patch net-next-2.6 4/4] bridge: implement slave management
 operations
Date: Mon, 28 Feb 2011 14:17:29 -0800
Message-ID: <20110228141729.09c3b770@nehalam>
References: <20110211152125.GA2763@psychotron.brq.redhat.com>
	<20110211152346.GD2763@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kaber@trash.net,
	fubar@us.ibm.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44335 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752252Ab1B1WRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 17:17:55 -0500
In-Reply-To: <20110211152346.GD2763@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Feb 2011 16:23:47 +0100
Jiri Pirko <jpirko@redhat.com> wrote:

> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

NAK
This does not belong in ethtool. It should be done by rt_netlink_ops.
I am working on doing that right now.


-- 
