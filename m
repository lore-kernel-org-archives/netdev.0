From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipip: Add room for user-specified custom
 header
Date: Wed, 14 Aug 2013 13:39:29 -0700 (PDT)
Message-ID: <20130814.133929.975837205960955245.davem@davemloft.net>
References: <1376296778-1983-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kristian.evensen@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760255Ab3HNUjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 16:39:31 -0400
In-Reply-To: <1376296778-1983-1-git-send-email-kristian.evensen@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>
Date: Mon, 12 Aug 2013 10:39:38 +0200

> This patch adds support for specifying the size of a custom header to be
> inserted between the two IP headers. The actual content will be inserted later,
> for example by a module that is attached to a hook.
> 
> A use-case for the feature provided by this patch is to ease the implementation
> of custom tunneling protocols. Instead of implementing them directly in the
> kernel and having to look out for changes in the kernel behavior/APIs, a
> tunneling protocol can be implemented as an independent module.
> 
> To avoid breaking user space (by updating ip_tunnel_params), it is only possible
> to specify the custom header length when an IPIP-tunnel is created using
> netlink-messages.
> 
> Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>

Sorry I'm not even going to consider applying this until you post
use-cases for this feature, because right now it just looks like a
random way to facilitate some third party proprietary kernel module
or similar.
