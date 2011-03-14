From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 30952] New: asix driver broken since 2.6.35
Date: Mon, 14 Mar 2011 14:57:55 -0700 (PDT)
Message-ID: <20110314.145755.35037972.davem@davemloft.net>
References: <20110314144309.a303662f.akpm@linux-foundation.org>
	<20110314.144553.70194816.davem@davemloft.net>
	<20110314144954.b87fdd64.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, lipski.bogdan@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56379
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751983Ab1CNV5S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 17:57:18 -0400
In-Reply-To: <20110314144954.b87fdd64.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Mon, 14 Mar 2011 14:49:54 -0700

> But that's without having looked at the vendor code.  Is it a Big Mess?

The vendor took the upstream driver at a point a year or two in the
past then did whatever they want with it.

They made no effort to "merge" in changes made to the upstream driver
during this time, so there is serious divergence especially in the PHY
handling which is probably where all the problems are in the upstream
driver.

Even the table of device IDs for probing is orderred and arranged
differently.
