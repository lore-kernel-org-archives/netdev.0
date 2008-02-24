From: Phil Oester <kernel@linuxace.com>
Subject: Re: [PATCH] Fix multicast on VLAN interfaces
Date: Sat, 23 Feb 2008 22:32:52 -0800
Message-ID: <20080224063252.GA4846@linuxace.com>
References: <20080221220542.GA19693@linuxace.com> <20080223.200018.128938227.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adsl-67-120-171-161.dsl.lsan03.pacbell.net ([67.120.171.161]:38513
	"HELO linuxace.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751033AbYBXGcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 01:32:54 -0500
Content-Disposition: inline
In-Reply-To: <20080223.200018.128938227.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 23, 2008 at 08:00:18PM -0800, David Miller wrote:
> "da" is kzalloc()'d, how can da->da_synced not be zero?

Because it was originally kmalloc'd, not kzalloc'd.  It was
fixed about 2 days prior to my patch submission, here:

    http://marc.info/?l=linux-netdev&m=120343348811767&w=2

which I missed.

Phil
