From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax: fix oops in wimax_dev_get_by_genl_info() when
 looking up non-wimax iface
Date: Thu, 12 Feb 2009 17:00:27 -0800 (PST)
Message-ID: <20090212.170027.225580891.davem@davemloft.net>
References: <1234479892-23695-1-git-send-email-inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wimax@linuxwimax.org, netdev@vger.kernel.org
To: inaky@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48525
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755152AbZBMBAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2009 20:00:32 -0500
In-Reply-To: <1234479892-23695-1-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Thu, 12 Feb 2009 15:04:52 -0800

> When a non-wimax interface is looked up by the stack, a bad pointer is
> returned when the looked-up interface is not found in the list (of
> registered WiMAX interfaces). This causes an oops in the caller when
> trying to use the pointer.
> 
> Fix by properly setting the pointer to NULL if we don't exit from the
> list_for_each() with a found entry.
> 
> Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>

Applied, thanks.
