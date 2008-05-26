From: David Miller <davem@davemloft.net>
Subject: Re: Version numbering
Date: Sun, 25 May 2008 22:53:39 -0700 (PDT)
Message-ID: <20080525.225339.94300435.davem@davemloft.net>
References: <20080523193210.GB26044@localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, benli@broadcom.com
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54824
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751414AbYEZFxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2008 01:53:43 -0400
In-Reply-To: <20080523193210.GB26044@localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Fri, 23 May 2008 12:32:10 -0700

> Hi David.  I'm sitting on a small patchset of bugfixes destined for the
> net-2.6 tree, but I'm a little confused about how I should handle the
> version numbering.
> 
> Right now, the net-2.6 tg3 driver is at version 3.92.  The net-next-2.6
> tree has 5785 support added and has a version of 3.93.  If we apply
> these patches to the net-2.6 driver, we will want to increase the
> version number.  How would you prefer we handle this?

Maybe what we can do is add another sub-version field.  So the stable
bug fixed driver in net-2.6 would end up being 3.92.1 or something
like that.
