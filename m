From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] tunnels: Allow IPv6 UDP checksums to be correctly
 controlled.
Date: Thu, 21 Jan 2016 15:57:15 +0100
Message-ID: <20160121155715.511dfc8e@griffin>
References: <1453335767-49234-1-git-send-email-jesse@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56494 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965309AbcAUO5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2016 09:57:19 -0500
In-Reply-To: <1453335767-49234-1-git-send-email-jesse@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Jan 2016 16:22:47 -0800, Jesse Gross wrote:
> When configuring checksums on UDP tunnels, the flags are different
> for IPv4 vs. IPv6 (and reversed). However, when lightweight tunnels
> are enabled the flags used are always the IPv4 versions, which are
> ignored in the IPv6 code paths. This uses the correct IPv6 flags, so
> checksums can be controlled appropriately.
> 
> Fixes: a725e514 ("vxlan: metadata based tunneling for IPv6")
> Fixes: abe492b4 ("geneve: UDP checksum configuration via netlink")
> Signed-off-by: Jesse Gross <jesse@kernel.org>

Indeed. Thanks for spotting this.

Acked-by: Jiri Benc <jbenc@redhat.com>
