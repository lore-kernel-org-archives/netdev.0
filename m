From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/3] igb: prevent skb_over panic w/ mtu smaller
 than 1K
Date: Sat, 31 Jan 2009 00:53:41 -0800 (PST)
Message-ID: <20090131.005341.30242349.davem@davemloft.net>
References: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
	<20090131005404.1466.30069.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59957
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751506AbZAaIxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 03:53:45 -0500
In-Reply-To: <20090131005404.1466.30069.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 30 Jan 2009 16:54:04 -0800

> A panic has been observed with frame sizes smaller than 1K.  This has been
> root caused to the hardware spanning larger frames across multiple buffers
> and then reporting the original frame size in the first descriptor.  To
> prevent this we can enable set the LPE bit which in turn will restrict
> packet sizes to those set in the RLPML register.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
