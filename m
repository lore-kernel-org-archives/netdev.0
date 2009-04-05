From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [RFT][PATCH 0/3] NET: Shutdown fixes for e1000, e1000e and ixgbe
Date: Sun, 5 Apr 2009 00:59:44 -0700
Message-ID: <9929d2390904050059t4f38428fn145aa615f850dd1f@mail.gmail.com>
References: <200904042337.31706.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Yinghai Lu <yinghai@kernel.org>,
	pm list <linux-pm@lists.linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:30087 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756439AbZDEH7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Apr 2009 03:59:47 -0400
In-Reply-To: <200904042337.31706.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 4, 2009 at 2:37 PM, Rafael J. Wysocki <rjw@sisk.pl> wrote:
> Hi,
>
> Commit 3fe7c4c9dca4fbbff92eb61a660690dad7029ec3 (net/igb: Fix kexec with igb
> (rev. 3)) fixed a kexec problem with igb by making its shutdown routine only
> put the device into a low power state if the system is going to be powered off.
>
> The following three patches make analogous changes to e1000, e1000e and ixgbe.
>

Thanks Rafael, I will add these patches to my tree and get them into
testing on Monday/Tuesday.  If everything looks good after testing, I
will push them with our other patches.

-- 
Cheers,
Jeff
