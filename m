From: Adam Majer <adamm@zombino.com>
Subject: Re: [PATCH 1/2] Issue NETDEV_CHANGE notification when bridge
 changes state
Date: Sun, 6 Mar 2011 18:25:43 -0600
Message-ID: <20110307002543.GA4242@mira.lan.galacticasoftware.com>
References: <20110306051833.GA3098@mira.lan.galacticasoftware.com>
 <1154832100.13939.1299393783798.JavaMail.root@tahiti.vyatta.com>
 <20110306080328.GA3850@mira.lan.galacticasoftware.com>
 <20110306094541.53390b55@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from polaris.galacticasoftware.com ([216.55.199.131]:49119 "EHLO
	polaris.galacticasoftware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752200Ab1CGA0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 Mar 2011 19:26:14 -0500
Content-Disposition: inline
In-Reply-To: <20110306094541.53390b55@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 06, 2011 at 09:45:41AM -0800, Stephen Hemminger wrote:
> Since this a generic problem, it needs a better solution.
> Sending NETDEV_CHANGE impacts lots of other pieces, and even
> user space has similar problems.

It does seem a little broad notification type. I've checked over
all the currently defined NETDEV notifiers, and it seems that
NETDEV_NOTIFY_PEERS may be a better option to use when bridge
has a potential topology change.

Currently it is only used in ipv4/devinet.c: where it is used to issue
a gratuitous ARP.


-- 
Adam Majer
adamm@zombino.com
