From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: cpts: Fix build error caused by include of plat/clock.h
Date: Fri, 14 Dec 2012 08:13:00 +0100
Message-ID: <20121214071300.GA2253@netboy.at.omicron.at>
References: <20121213213641.GF4989@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:48030 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab2LNHNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2012 02:13:12 -0500
Content-Disposition: inline
In-Reply-To: <20121213213641.GF4989@atomide.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 13, 2012 at 01:36:41PM -0800, Tony Lindgren wrote:
> Commit 87c0e764 (cpts: introduce time stamping code and a PTP hardware clock)
> mistakenly included plat/clock.h that should not be included by drivers
> even if it exists.

Hasn't this already been fixed?

  https://patchwork.kernel.org/patch/1810481/
  http://www.spinics.net/lists/linux-omap/msg83132.html

Thanks,
Richard
