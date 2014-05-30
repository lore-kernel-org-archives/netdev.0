From: Benjamin Poirier <benjamin.poirier@gmail.com>
Subject: Re: [PATCH 2/3] cnic: Don't take cnic_dev_lock in
 cnic_alloc_uio_rings()
Date: Fri, 30 May 2014 15:33:20 -0700
Message-ID: <20140530223320.GA23581@f1.synalogic.ca>
References: <1401491923-5480-1-git-send-email-mchan@broadcom.com>
 <1401491923-5480-2-git-send-email-mchan@broadcom.com>
 <1401491923-5480-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, nhorman@tuxdriver.com
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:35098 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbaE3WdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 18:33:23 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so2186112pbc.40
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 15:33:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1401491923-5480-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/05/30 16:18, Michael Chan wrote:
> We are allocating memory with GFP_KERNEL under spinlock.  Since this is
> the only call manipulating the cnic_udev_list and it is always under
> rtnl_lock, cnic_dev_lock can be safely removed.

In that case, the many other instances of cnic_dev_lock throughout cnic
should also be removed, no?
