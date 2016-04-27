From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 08/15] i40e: Allow user to change input set mask for
 flow director
Date: Tue, 26 Apr 2016 23:48:14 -0400 (EDT)
Message-ID: <20160426.234814.31916479145118247.davem@davemloft.net>
References: <1461704148-114349-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1461704148-114349-9-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kiran.patil@intel.com, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751848AbcD0DsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 23:48:16 -0400
In-Reply-To: <1461704148-114349-9-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 26 Apr 2016 13:55:41 -0700

> From: Kiran Patil <kiran.patil@intel.com>
> 
> This patch implements feature, which allows user to change
> input set mask for flow director using side-band channel.
> This patch adds definition of FLOW_TYPE_MASK into the header file.
> With this patch, user can now specify less than 4 tuple(src ip, dsp ip,
> src port, dst port) for flow type TCP4/UDP4.
> 
> Change-Id: I90052508f8c172c0da5a4b78b949704b4a59ea78
> Signed-off-by: Kiran Patil <kiran.patil@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

If you want to do this, you have to define the semantics generically
in include/uapi/linux/ethtool.h so that other drivers can implement
this too.

Please don't ever implement private, driver specific, interpretations
of the generic ethtool facilitites.

The semantics and interpretations of the values must absolutely be
consistent across all drivers in the tree.

Otherwise the user experience is terrible.

Thanks.
