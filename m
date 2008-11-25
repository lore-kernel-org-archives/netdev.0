From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 00/39] merge request for WiMAX kernel stack and i2400m driver
Date: Tue, 25 Nov 2008 08:57:10 -0800
Message-ID: <200811250857.10919.inaky@linux.intel.com>
References: <cover.1227562829.git.inaky@linux.intel.com> <20081125.004736.149304104.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:53117 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753898AbYKYQ5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 11:57:44 -0500
In-Reply-To: <20081125.004736.149304104.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 25 November 2008, David Miller wrote:
> From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
> Date: Mon, 24 Nov 2008 13:50:23 -0800
>
> > This patchset (or the linux-wimax GIT tree at git.kernel.org) merges
> > the WiMAX subsystem and driver for the Intel 2400m Wireless WiMAX
> > connection to the tree. We'd like to get it in for the 2.6.29 merge
> > window.
>
> You've made this difficult by creating the dependency on
> the USB changes.
>
> So I can't, for example, merge this into the networking tree.
> Is there some way you can make the driver work without the
> USB changes even with some hack?

I know, but there was little choice. The error paths for device 
recovery depend on those changes. That's why I suggest posting 
through gregkh's tree once you guys give your approval. Then after
it goes into the first merge window and it permeates to your tree,
I'll rebase the linux-wimax tree to have you as upstream.

> Second, put the wimax stack stuff under net/wimax just like
> we do for net/mac80211 et al.  Then just the drivers go under
> drivers/net/wimax

Oh, good point. Will do.

I'll send updated patches today.

Thanks,

-- 
Inaky
