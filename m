From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND 2.6.27] netlink: Remove compat API for nested
 attributes
Date: Tue, 02 Sep 2008 17:34:04 -0700 (PDT)
Message-ID: <20080902.173404.87370341.davem@davemloft.net>
References: <48BDB434.1040805@intel.com>
	<20080902232008.GD20815@postel.suug.ch>
	<48BDD9F0.8090706@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752433AbYICAeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 20:34:10 -0400
In-Reply-To: <48BDD9F0.8090706@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Tue, 02 Sep 2008 17:27:28 -0700

> That is the point of code like this.  It defines a standard set of
> tools for extending an existing netlink interface.  If nothing else
> we should standardize on the netem approach for both parsing and
> creation since prio no longer ueses the compat attributes.

If there are no more users, and the netem case is a specialized format
we don't want to encourage anyone to ever use in the future (and we
certainlt DON'T), we delete the interface.
