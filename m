From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] sysfs: remove error messages for -EEXIST case
Date: Wed, 14 May 2008 22:34:29 -0700 (PDT)
Message-ID: <20080514.223429.249318607.davem@davemloft.net>
References: <20080514170316.672f809d@extreme>
	<20080514181257.74fbb5aa@extreme>
	<20080514181603.411e834f@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, fubar@us.ibm.com, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36410
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751904AbYEOFee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 01:34:34 -0400
In-Reply-To: <20080514181603.411e834f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 14 May 2008 18:16:03 -0700

> It is possible that the entry in sysfs already exists, one case of this is
> when a network device is renamed to bonding_masters. Anyway, in this case
> the proper error path is for device_rename to return an error code, not to
> generate bogus backtrace and errors.
> 
> Also, to avoid possible races, the create link should be done before the
> remove link. This makes a device rename atomic operation like other renames.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
