From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 4/4] igb: enable auxiliary PHC functions for the
 i210.
Date: Wed, 29 May 2013 09:24:45 +0200
Message-ID: <20130529072445.GA4868@netboy>
References: <20130528162325.GD4678@netboy>
 <CDCA3AA1.1E8D4%matthew.vick@intel.com>
 <02874ECE860811409154E81DA85FBB58564F1C88@ORSMSX104.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:41856 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935074Ab3E2HYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 03:24:51 -0400
Received: by mail-ee0-f44.google.com with SMTP id b57so5207419eek.3
        for <netdev@vger.kernel.org>; Wed, 29 May 2013 00:24:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB58564F1C88@ORSMSX104.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 28, 2013 at 09:12:02PM +0000, Keller, Jacob E wrote:
> 
> I think ethtool would be good, but what about using sysfs?

The problem I see with ethtool is that configuring GPIOs (and these
SDPs are really just GPIOs by a different name) is really the job of
the device tree. But of course, most x86 users of the i210 don't have
this option.

Also, using ethtool or sysfs is not really attractive for embedded
designs (let's not forget the poor embedded guys). I think we need to
have a way to specify the pin functions at (or before) kernel boot
time.  Barring DT and kconfig, using a module parameter is the only
way to accomplish this.

Thanks,
Richard
