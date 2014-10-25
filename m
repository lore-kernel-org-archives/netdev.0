From: David Miller <davem@davemloft.net>
Subject: Re: [net] i40e: _MASK vs _SHIFT typo in i40e_handle_mdd_event()
Date: Sat, 25 Oct 2014 16:51:14 -0400 (EDT)
Message-ID: <20141025.165114.393013592458178740.davem@davemloft.net>
References: <1414033589-7544-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751583AbaJYUv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Oct 2014 16:51:27 -0400
In-Reply-To: <1414033589-7544-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 22 Oct 2014 20:06:29 -0700

> From: Dan Carpenter <dan.carpenter@oracle.com>
> 
> We accidentally mask by the _SHIFT variable.  It means that "event" is
> always zero.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> Tested-by: Jim Young <jamesx.m.young@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.
