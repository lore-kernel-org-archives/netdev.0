From: David Dillow <dave@thedillows.org>
Subject: Re: r8169c: Support for Realtek 8168DP chip?
Date: Thu, 01 Oct 2009 09:38:30 -0400
Message-ID: <1254404310.24972.4.camel@obelisk.thedillows.org>
References: <4AC494EC.8050405@ts.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rainer Koenig <Rainer.Koenig@ts.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.knology.net ([24.214.63.101]:33641 "EHLO smtp.knology.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756240AbZJANi2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 09:38:28 -0400
In-Reply-To: <4AC494EC.8050405@ts.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-01 at 13:39 +0200, Rainer Koenig wrote:
> The reason why is easy to decode when looking at the source: The
> TxConfig register returns 2b800000 and there is no MAC_VERSION in the
> list of valid versions. That means not PHY initialization code is
> executed and stop, no working device. :-(

Francois Romieu posted a patch yesterday (today, his time) to the thread
"r8169 chips on some Intel D945GSEJT boards fail to work after PXE boot"

It looks to add MAC support for your card; you should be able to find it
at any of your favorite mail archives, Google, or better yet,
http://patchwork.ozlabs.org/project/netdev/list/

Hmm, patchwork doesn't seem to have picked it up, yet.

Please test that and let us know how it works.
Dave

