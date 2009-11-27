From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] macvlan: allow in-kernel modules to create and manage macvlan devices
Date: Fri, 27 Nov 2009 23:14:42 +0100
Message-ID: <200911272314.42641.arnd@arndb.de>
References: <20091113195201.11184.25766.stgit@mimic.site> <20091113195529.11184.19011.stgit@mimic.site>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, bridge@lists.linux-foundation.org
To: Patrick Mullaney <pmullaney@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:50250 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751749AbZK0WOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 17:14:39 -0500
In-Reply-To: <20091113195529.11184.19011.stgit@mimic.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 13 November 2009, Patrick Mullaney wrote:
> 
> The macvlan driver didn't allow for creation/deletion of devices
> by other in-kernel modules. This patch provides common routines
> for both in-kernel and netlink based management. This patch
> also enables macvlan device support for gro for lower level
> devices that support gro.

I wonder if doing this way round is a good idea, why don't
you just use netlink to set up the endpoint device like
the current macvlan and macvtap do? I think doing it consistently
for all backends would be a significant advantage.

	Arnd <><
