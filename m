From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch for 2.6.27? 3/6] e1000: prevent corruption of EEPROM/NVM
Date: Thu, 18 Sep 2008 21:41:09 -0400
Message-ID: <48D30335.1070908@garzik.org>
References: <200809052104.m85L46VE020352@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisl@vmware.com, arvidjaar@mail.ru,
	bruce.w.allan@intel.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	peter.p.waskiewicz.jr@intel.com, pratap@vmware.com, zach@vmware.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:38998 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754968AbYISBlQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 21:41:16 -0400
In-Reply-To: <200809052104.m85L46VE020352@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Christopher Li <chrisl@vmware.com> 
> 
> Andrey reports e1000 corruption, and that a patch in vmware's ESX fixed
> it.
> 
> The EEPROM corruption is triggered by concurrent access of the EEPROM
> read/write. Putting a lock around it solve the problem.
> 
> [akpm@linux-foundation.org: use DEFINE_SPINLOCK to avoid confusing lockdep]
> Signed-off-by: Christopher Li <chrisl@vmware.com>
> Reported-by: Andrey Borzenkov <arvidjaar@mail.ru>
> Cc: Zach Amsden <zach@vmware.com>
> Cc: Pratap Subrahmanyam <pratap@vmware.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Cc: Bruce Allan <bruce.w.allan@intel.com>
> Cc: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> Cc: John Ronciak <john.ronciak@intel.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/e1000/e1000_hw.c |   23 +++++++++++++++++++++++
>  1 file changed, 23 insertions(+)

No further reply from Intel to my ping, and this regression needs to be 
addressed, so, applied.


