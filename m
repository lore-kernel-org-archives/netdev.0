From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/12 net-2.6.25] [NETNS]: Re-export init_net via
 EXPORT_SYMBOL.
Date: Tue, 22 Jan 2008 22:08:37 -0800 (PST)
Message-ID: <20080122.220837.15849277.davem@davemloft.net>
References: <1201017566-16985-5-git-send-email-den@openvz.org>
	<47962228.3000302@trash.net>
	<4796258F.7050507@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, den@openvz.org, netdev@vger.kernel.org,
	devel@openvz.org, containers@lists.osdl.org
To: dlunev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36084
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752386AbYAWGI3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 01:08:29 -0500
In-Reply-To: <4796258F.7050507@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <dlunev@gmail.com>
Date: Tue, 22 Jan 2008 20:19:11 +0300

> Patrick McHardy wrote:
> > Denis V. Lunev wrote:
> >> init_net is used added as a parameter to a lot of old API calls, f.e.
> >> ip_dev_find. These calls were exported as EXPORT_SYMBOL. So, export
> >> init_net
> >> as EXPORT_SYMBOL to keep networking API consistent.
> > 
> > 
> > I think this should go in 2.6.24 if still possible so people
> > don't have to find workarounds that will be obsolete one
> > version later.
> > 
> yep, sure :) should I send this one separate for 2.4?

I'll take care of this.
