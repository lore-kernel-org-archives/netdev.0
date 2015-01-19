From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phonet netlink: allow multiple messages per skb in
 route dump
Date: Mon, 19 Jan 2015 16:20:46 -0500 (EST)
Message-ID: <20150119.162046.967451324075209369.davem@davemloft.net>
References: <1421666124-16055-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sakari.ailus@nokia.com,
	courmisch@gmail.com, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34991 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbASVUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 16:20:49 -0500
In-Reply-To: <1421666124-16055-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 19 Jan 2015 12:15:24 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> My previous patch to this file changed the code to be bug-compatible
> towards userspace. Unless userspace (which I wasn't able to find)
> implements the dump reader by hand in a wrong way, this isn't needed.
> If it uses libnl or similar code putting multiple messages into a
> single SKB is far more efficient.
> 
> Change the code to do this. While at it, also clean it up and don't
> use so many variables - just store the address in the callback args
> directly.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks.
