From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] e1000e: replace incorrect use of GG82563_REG macro
Date: Tue, 08 Dec 2009 20:11:00 -0800 (PST)
Message-ID: <20091208.201100.146348614.davem@davemloft.net>
References: <20091208172725.19741.25809.stgit@localhost.localdomain>
	<20091208172800.19741.84491.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37900
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756673AbZLIEKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 23:10:53 -0500
In-Reply-To: <20091208172800.19741.84491.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Tue, 08 Dec 2009 09:28:01 -0800

> From: Bruce Allan <bruce.w.allan@intel.com>
> 
> The GG82563_REG() macro should not be used to determine the offset provided
> to the e1000e_[read|write]_kmrn_reg() functions since the first argument to
> the macro is already implied and gets masked off anyway in the functions.
> The resultant register reads/writes with this patch are functionally the
> same as before.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
