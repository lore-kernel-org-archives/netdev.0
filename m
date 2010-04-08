From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: Crashes in xfrm_lookup
Date: Thu, 8 Apr 2010 12:31:59 +0100
Message-ID: <20100408113158.GA30647@rakim.wolfsonmicro.main>
References: <20100408111441.GA14241@sirena.org.uk>
 <4BBDBCF9.5060906@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:50061 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750768Ab0DHLcC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:32:02 -0400
Content-Disposition: inline
In-Reply-To: <4BBDBCF9.5060906@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 08, 2010 at 02:24:41PM +0300, Timo Ter=E4s wrote:

> Probably the same as http://marc.info/?t=3D127071006600005&r=3D1&w=3D=
2

> Happens because CONFIG_XFRM_SUB_POLICY is not enabled, and one of
> the helper functions I used did unexpected things in that case.

> Try the following:

Yes, that seems to make things much happier - thanks!  I do have one
patch I came up with while I was looking at the code (though I'm not
sure it's correct), I'll post that once I've had lunch.
