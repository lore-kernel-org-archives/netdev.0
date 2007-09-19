From: David Miller <davem@davemloft.net>
Subject: Re: follow-up: discrepancy with POSIX
Date: Wed, 19 Sep 2007 09:52:51 -0700 (PDT)
Message-ID: <20070919.095251.45154496.davem@davemloft.net>
References: <46F13E8B.4050309@redhat.com>
	<p73sl5aveqh.fsf@bingen.suse.de>
	<46F15305.2030507@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: drepper@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57745
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754900AbXISQxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 12:53:06 -0400
In-Reply-To: <46F15305.2030507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ulrich Drepper <drepper@redhat.com>
Date: Wed, 19 Sep 2007 09:49:09 -0700

> But the spec calls for a "null address" to be used and that's in my
> understanding something different from using AF_UNSPEC.

It just occured to me that AF_UNSPEC might be used simply
because "all zeros" might be a valid real bindable address
for some address family.  And using AF_UNSPEC avoids that
problem entirely.
