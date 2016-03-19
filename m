From: Joe Perches <joe@perches.com>
Subject: Re: [RFC net-next 0/2] Create ancient subdirectories for old
 hardware
Date: Fri, 18 Mar 2016 19:28:02 -0700
Message-ID: <1458354482.26915.35.camel@perches.com>
References: <1458340518.26915.30.camel@perches.com>
	 <cover.1458347329.git.joe@perches.com>
	 <20160318.221153.997255526626920777.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0237.hostedemail.com ([216.40.44.237]:46303 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751086AbcCSC2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 22:28:06 -0400
In-Reply-To: <20160318.221153.997255526626920777.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-03-18 at 22:11 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Fri, 18 Mar 2016 17:33:29 -0700
>=20
> > Maybe something like this:
> >=A0
> > Old, rare, and unsupported hardware should be exposed as ancient.
> >=A0
> > The drivers for these ancient hardwares are generally untested with
> > current kernels.
>=20
> Moving drivers has a long term maintainence cost.
>=20
> If they've moved into drivers/net proper, we have to maintain
> them there forever.

I don't doubt that.

All files are still in drivers/net, just possibly in
separate subdirectories for easier visibility to
determine if changes like what were proposed for cxgb
should actually be done or not.
