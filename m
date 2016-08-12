From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2] ip route: restore_handler should check
 tb[RTA_PREFSRC] for local networks
Date: Fri, 12 Aug 2016 17:43:45 +0200
Message-ID: <20160812154345.GL10197@orbyte.nwl.cc>
References: <f805ffe5dad63ae04330df32bbe6cf532a6772b7.1470561150.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, stephen@networkplumber.org
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60911 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752203AbcHLPns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 11:43:48 -0400
Content-Disposition: inline
In-Reply-To: <f805ffe5dad63ae04330df32bbe6cf532a6772b7.1470561150.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 07, 2016 at 05:12:30PM +0800, Xin Long wrote:
> Prior to this patch, If one route entry's RTA_PREFSRC and RTA_GATEWAY
> both were NULL, it was supposed to be restored ONLY as a local address.
> 
> But as it didn't check tb[RTA_PREFSRC] when restoring local networks,
> rtattr_cmp would return a success if it was NULL, this route entry would
> be restored again as a local network.
> 
> This patch is to add tb[RTA_PREFSRC] check when restoring local networks.
> 
> Fixes: 74af8dd9620e ("ip route: restore route entries in correct order")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Tested-by: Phil Sutter <phil@nwl.cc>
