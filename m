From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next-2.6 PATCH] net: device name allocation cleanups
Date: Tue, 17 Nov 2009 16:42:14 -0800
Message-ID: <20091117164214.3d37accb@nehalam>
References: <200911171849.03870.opurdila@ixiacom.com>
	<20091117090157.2a07bed5@nehalam>
	<200911172233.53119.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56565 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbZKRAmX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Nov 2009 19:42:23 -0500
In-Reply-To: <200911172233.53119.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 17 Nov 2009 22:33:53 +0200
Octavian Purdila <opurdila@ixiacom.com> wrote:

> +static int dev_get_valid_name(struct net *net, const char *name, char *buf,
> +			      int fmt)
                           
you are using fmt as a boolean so declare it 'bool'?

-- 
