From: Alex Williamson <alex.williamson@hp.com>
Subject: Re: [GIT]: Networking
Date: Fri, 05 Sep 2008 09:08:12 -0600
Message-ID: <1220627292.7260.3.camel@2710p.home>
References: <20080827.164649.87042354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jouni.malinen@atheros.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:4465 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbYIEPIQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 11:08:16 -0400
In-Reply-To: <20080827.164649.87042354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-08-27 at 16:46 -0700, David Miller wrote:

> 22) Two mac80211 bug fixes from Jouni Malinen:
>     a) Use IWEVCUSTOM so that we don't hit the 256 byte limit that
>        IWEVASSOCREQIE has

This one breaks wireless with 32bit userspace/64bit kernel.  Bisected
back to changeset 087d833e5a9f67ba933cb32eaf5a2279c1a5b47c:

mac80211: Use IWEVASSOCREQIE instead of IWEVCUSTOM

-- 
Alex Williamson                             HP Open Source & Linux Org.

