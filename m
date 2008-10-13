From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 11655] New: /proc/sys/net/ipv6/conf/all/*
 controls don't work
Date: Mon, 13 Oct 2008 00:32:39 -0700 (PDT)
Message-ID: <20081013.003239.89070363.davem@davemloft.net>
References: <bug-11655-10286@http.bugzilla.kernel.org/>
	<20081002231826.869a1a9e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	adwol@zonk.pl
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57821
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754161AbYJMHdC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2008 03:33:02 -0400
In-Reply-To: <20081002231826.869a1a9e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 2 Oct 2008 23:18:26 -0700

> (switched to email.  Please respond via emailed reply-to-all, not via the
> bugzilla web interface).

Not a bug.

These "global" setting have to be set to the desired value before the
device is created.  And it is at creation time that these global
values are "inherited" by the device.

Afterwards changes to the global value will not propagate to those
devices again, because that might override a changed setting made
by the user.

It is only newly created devices which get these values.
