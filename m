From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH net-next 1/2] mlx4_en: Add PTP hardware clock
Date: Wed, 18 Dec 2013 09:03:04 -0600
Message-ID: <20131218150304.GB3857@sbohrermbp13-local.rgmadvisors.com>
References: <1387312359-9476-1-git-send-email-shawn.bohrer@gmail.com>
 <1387312359-9476-2-git-send-email-shawn.bohrer@gmail.com>
 <CAJZOPZKLSThnWCycVFF1dzoDuks48prUvzSN_us9NYTz82wRsA@mail.gmail.com>
 <20131217214615.GD8693@sbohrermbp13-local.rgmadvisors.com>
 <52B155F7.2070505@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <or.gerlitz@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	tomk@rgmadvisors.com, Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f51.google.com ([209.85.128.51]:39253 "EHLO
	mail-qe0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754600Ab3LRPDK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 10:03:10 -0500
Received: by mail-qe0-f51.google.com with SMTP id 1so6527192qee.38
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 07:03:09 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <52B155F7.2070505@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 09:59:51AM +0200, Or Gerlitz wrote:
> On 17/12/2013 23:46, Shawn Bohrer wrote:
> >v3: is code identical to v2.  I simply finished testing it with
> >linuxptp, cleaned up the commit description a little and sent to davem.
> so the problem you saw with V2 is understood && gone with V3?

The main problem I saw with linuxptp is fixed with patch 2/2:

mlx4_en: Only cycle port if HW timestamp config changes

So yes, again v3 is code identical to v2, and from my testing appears
to work as designed.

--
Shawn
