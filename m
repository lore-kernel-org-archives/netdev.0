From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 2/2] e1000e: fix potential NVM corruption on
 ICH9 with 8K bank size
Date: Sun, 09 Aug 2009 21:47:50 -0700 (PDT)
Message-ID: <20090809.214750.145796277.davem@davemloft.net>
References: <20090807174136.31114.96240.stgit@localhost.localdomain>
	<20090807174155.31114.81083.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751781AbZHJErl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 00:47:41 -0400
In-Reply-To: <20090807174155.31114.81083.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 07 Aug 2009 10:41:56 -0700

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The bank offset was being incorrectly calculated on ICH9 parts with a bank
> size of 8K (instead of the more common 4K bank) which would cause any NVM
> writes to be done on the wrong address after switching from bank 1 to bank
> 0.  Additionally, assume we are meant to use bank 0 if a valid bank is not
> detected, and remove the unnecessary acquisition of the SW/FW/HW semaphore
> when writing to the shadow ram version of the NVM image.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
