From: Guenter <linux@roeck-us.net>
Subject: Re: [PATCH 2/2] net: dsa: mv88e6xxx: call _mv88e6xxx_stats_wait with
 SMI lock held
Date: Fri, 10 Jul 2015 10:13:26 -0700
Message-ID: <20150710171326.GC6585@groeck-UX31A>
References: <1436547449-26927-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1436547449-26927-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34120 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932380AbbGJRNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 13:13:30 -0400
Content-Disposition: inline
In-Reply-To: <1436547449-26927-2-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 12:57:29PM -0400, Vivien Didelot wrote:
> At switch setup, _mv88e6xxx_stats_wait was called without holding the
> SMI mutex. Fix this by requesting the lock for this call.
> 
> Also, return the _mv88e6xxx_stats_wait code, since it may fail.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Good catch.

Reviewed-by: Guenter Roeck <linux@roeck-us.net>
