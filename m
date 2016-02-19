From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] lwt: fix rx checksum setting for lwt devices
 tunneling over ipv6
Date: Fri, 19 Feb 2016 15:40:31 -0500 (EST)
Message-ID: <20160219.154031.711717032204820849.davem@davemloft.net>
References: <244994c83cb73d98205f39aaefcee846dab48260.1455731463.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@kernel.org, tgraf@suug.ch,
	jbenc@redhat.com, pshelar@nicira.com, tom@herbertland.com
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992835AbcBSUkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2016 15:40:33 -0500
In-Reply-To: <244994c83cb73d98205f39aaefcee846dab48260.1455731463.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Wed, 17 Feb 2016 19:30:01 +0100

> the commit 35e2d1152b22 ("tunnels: Allow IPv6 UDP checksums to be
> correctly controlled.") changed the default xmit checksum setting
> for lwt vxlan/geneve ipv6 tunnels, so that now the checksum is not
> set into external UDP header.
> This commit changes the rx checksum setting for both lwt vxlan/geneve
> devices created by openvswitch accordingly, so that lwt over ipv6
> tunnel pairs are again able to communicate with default values.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied.
