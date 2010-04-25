From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.33.2 networking regression
Date: Sat, 24 Apr 2010 20:19:07 -0700 (PDT)
Message-ID: <20100424.201907.104073503.davem@davemloft.net>
References: <20100425031656.GA27598@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752567Ab0DYDTC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 23:19:02 -0400
In-Reply-To: <20100425031656.GA27598@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Sat, 24 Apr 2010 23:16:57 -0400

> There don't appear to be any direct changes to via-velocity.c in the
> diff, so I'm really confused. Any clues ? I'll bisect it, but it
> probably won't be until Monday..

Looks like some x86/PCI/ACPI change causes this, rather than a
networking change.
