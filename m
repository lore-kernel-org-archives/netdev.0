From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 04/04] smc91x: add insw/outsw to default config
Date: Thu, 21 Feb 2008 11:41:51 +0900
Message-ID: <aec7e5c30802201841i57669bd0v38d0cedf0589b76@mail.gmail.com>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
	 <20080220095821.22645.60604.sendpatchset@clockwork.opensource.se>
	 <alpine.LFD.1.00.0802201059080.2732@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: "Nicolas Pitre" <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.248]:57219 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbYBUClw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 21:41:52 -0500
Received: by ag-out-0708.google.com with SMTP id 33so4922188agc.1
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 18:41:52 -0800 (PST)
In-Reply-To: <alpine.LFD.1.00.0802201059080.2732@xanadu.home>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2008 at 1:00 AM, Nicolas Pitre <nico@cam.org> wrote:
> On Wed, 20 Feb 2008, Magnus Damm wrote:
>
>  > This patch makes sure SMC_insw()/SMC_outsw() are defined for the
>  > default configuration. Without this change BUG()s will be triggered
>  > when using 16-bit only platform data and the default configuration.
>  >
>  > Signed-off-by: Magnus Damm <damm@igel.co.jp>
>
>  You should have introduced this patch as 3/4 instead of 4/4 so to make
>  sure the series won't  create a non functional kernel between 3/4 and
>  4/4.

Yes, you are right. At least in theory. =) In practice this doesn't
matter so much since the boards modified by 3/4 are all in a
half-assed state. I'm working on fixing that up though, and using
platform data flags would be help a lot. =)

Speaking of smc91x and sh-boards, I guess the patch below is too late
for 2.6.25? We have the rest of the board support bits in place
already but no ethernet. I posted the smc91x patch below a bit too
late unfortunately _and_ i forgot to CC you, so my bad.

http://www.mail-archive.com/netdev@vger.kernel.org/msg61390.html

Thanks for your help!

/ magnus
