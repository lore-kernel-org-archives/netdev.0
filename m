From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 6/6][NETFILTER] Use the ctl paths instead of
 hand-made analogue
Date: Wed, 09 Jan 2008 00:34:22 -0800 (PST)
Message-ID: <20080109.003422.78089670.davem@davemloft.net>
References: <47839C30.2040402@openvz.org>
	<4783A0D1.4010202@openvz.org>
	<4783A12A.3060207@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57264
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751024AbYAIIeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:34:22 -0500
In-Reply-To: <4783A12A.3060207@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Tue, 08 Jan 2008 17:13:30 +0100

> Pavel Emelyanov wrote:
> > The conntracks subsystem has a similar infrastructure
> > to maintain ctl_paths, but since we already have it
> > on the generic level, I think it's OK to switch to
> > using it.
> > 
> > So, basically, this patch just replaces the ctl_table-s
> > with ctl_path-s, nf_register_sysctl_table with 
> > register_sysctl_paths() and removes no longer needed code.
> 
> Also looks good, thanks.

Also applied, thanks.

