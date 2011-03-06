From: Adam Majer <adamm@zombino.com>
Subject: Re: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge
 changes state
Date: Sun, 6 Mar 2011 02:03:28 -0600
Message-ID: <20110306080328.GA3850@mira.lan.galacticasoftware.com>
References: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
 <1154832100.13939.1299393783798.JavaMail.root@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from polaris.galacticasoftware.com ([216.55.199.131]:50396 "EHLO
	polaris.galacticasoftware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750892Ab1CFIDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 03:03:55 -0500
Content-Disposition: inline
In-Reply-To: <1154832100.13939.1299393783798.JavaMail.root@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 05, 2011 at 10:43:03PM -0800, Stephen Hemminger wrote:
> Why not set forwarding delay to zero? I don't think you are using STP?
> 
> P.s: removing linux-kernel mailing list, since there is no point
> in copying the whole world on this thread.

I just sent patches where MAINTAINERS file told me to send it. ;)

No, I'm not relying on STP. I think setting learning->forwarding delay
to 0 could cause problems with STP like loops until the loop is
detected.

There may be a better spot where to insert the notification that the
bridge is forwarding data, though I'm not exactly certain where. The
patch will cause bridge to issue NETDEV_CHANGE notification for all
topology changes. This may or may not be useful but shouldn't be
harmful (I can't imagine these occur very often?) The IPv6 autoconf
patch will only act on this if it doesn't have IPv6 address configured
manually or via autoconf.

-- 
Adam Majer
adamm@zombino.com
