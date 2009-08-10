From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 1/2] e1000e: fix acquisition of SW/FW/HW
 semaphore for ICHx parts
Date: Sun, 09 Aug 2009 21:47:45 -0700 (PDT)
Message-ID: <20090809.214745.67300334.davem@davemloft.net>
References: <20090807174136.31114.96240.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59224
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751762AbZHJErf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:47:35 -0400
In-Reply-To: <20090807174136.31114.96240.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 07 Aug 2009 10:41:37 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> For ICHx parts, write the EXTCNF_CTRL.SWFLAG bit once when trying to
> acquire the SW/FW/HW semaphore instead of multiple times to prevent the
> hardware from having problems (especially for systems with manageability
> enabled), and extend the timeout for the hardware to set the SWFLAG bit.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
