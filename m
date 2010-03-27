From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] igb: use correct bits to identify if
 managability is enabled
Date: Sat, 27 Mar 2010 08:33:46 -0700 (PDT)
Message-ID: <20100327.083346.189701887.davem@davemloft.net>
References: <20100326031506.10368.40559.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53698
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752929Ab0C0PdW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 11:33:22 -0400
In-Reply-To: <20100326031506.10368.40559.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 25 Mar 2010 20:15:06 -0700

> From: Alexander Duyck <alexander.h.duyck@intel.com>
> 
> igb was previously checking the wrong bits in the MANC register to determine
> if managability was enabled.  As a result it was incorrectly powering down and
> resetting the phy when it didn't need to.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
