From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [IPROUTE PATCH] libnetlink: Use ifinfomsg instead of rtgenmsg
 in rtnl_wilddump_req_filter
Date: Thu, 25 Apr 2013 16:17:03 -0700
Message-ID: <20130425161703.2a78ebd7@nehalam.linuxnetplumber.net>
References: <20130425220710.6520.32515.stgit@ahduyck-cp1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>, jeffrey.t.kirsher@intel.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:62244 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759603Ab3DYXRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 19:17:09 -0400
Received: by mail-pa0-f52.google.com with SMTP id fb1so2139866pad.25
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 16:17:08 -0700 (PDT)
In-Reply-To: <20130425220710.6520.32515.stgit@ahduyck-cp1.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 25 Apr 2013 15:07:10 -0700
Alexander Duyck <alexander.h.duyck@intel.com> wrote:

> This change corrects a kernel incompatibility that was resulting in the
> ext_filter_mask not being correctly discovered by the kernel as it is buried
> somewhere in the ifinfomsg.
> 
> Reported-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

This looks good, I will apply it unless there are objections.
