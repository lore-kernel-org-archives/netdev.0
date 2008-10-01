From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Multicast: add mc_count to in_device and to
 inet6_dev
Date: Wed, 01 Oct 2008 02:08:54 -0700 (PDT)
Message-ID: <20081001.020854.146740849.davem@davemloft.net>
References: <b25312890809302357j6b75dd27uced2968046c10993@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, pekkas@netcore.fi
To: roszenrami@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49623
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751963AbYJAJJF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 05:09:05 -0400
In-Reply-To: <b25312890809302357j6b75dd27uced2968046c10993@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <roszenrami@gmail.com>
Date: Wed, 1 Oct 2008 09:57:42 +0300

> Hi,
>     - This patch set adds mc_count to  struct in_device (IPv4) and to
> struct inet6_dev (IPv6) and updates increment/decrement/initialization
> of this field in IPv4 and in IPv6.
> 
> - Also printing the /proc entry (/proc/net/igmp) is adjusted to use
> the new mc_count.
> 
>  - Thanks to David Stevens for his feedback.

Why even add the mc_count to the ipv6 side if it isn't
even going to be used?  I see nothing actually reading
the ipv6 version of the value.

If you're going to do that eventually in some later
set of changes, add it then.
