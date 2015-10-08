From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v3 1/2] fix return of iptunnel_xmit
Date: Thu, 8 Oct 2015 18:19:13 +0200
Message-ID: <20151008181913.0d55f77f@griffin>
References: <1444320530-28706-1-git-send-email-aschultz@tpip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andreas Schultz <aschultz@tpip.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48732 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934141AbbJHQTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 12:19:17 -0400
In-Reply-To: <1444320530-28706-1-git-send-email-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  8 Oct 2015 18:08:49 +0200, Andreas Schultz wrote:
> All users of iptunnel_xmit expect the return value to be the packet
> length on success (>0), negative for a tx error and zero for a tx
> dropped error. In cset 0e6fbc5b6c6218987c93b8c7ca60cf786062899d the
> negative return case was lost.
> 
> This bug was introduced when the ip_tunnel_core code was refactored.
> 
> Fixes: 0e6fbc5b6c6218987c93b8c7ca60cf786062899d
> Signed-off-by: Andreas Schultz <aschultz@tpip.net>

Acked-by: Jiri Benc <jbenc@redhat.com>

-- 
Jiri Benc
