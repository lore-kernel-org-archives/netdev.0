From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH] e1000e: Add check for reset flags before
 displaying reset message
Date: Thu, 28 Oct 2010 10:20:15 -0700 (PDT)
Message-ID: <20101028.102015.112604932.davem@davemloft.net>
References: <20101028105955.27748.92516.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	carolyn.wyborny@intel.com, bruce.w.allan@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45558
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933965Ab0J1RTw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:19:52 -0400
In-Reply-To: <20101028105955.27748.92516.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 28 Oct 2010 03:59:55 -0700

> From: Carolyn Wyborny <carolyn.wyborny@intel.com>
> 
> Some parts need to execute resets during normal operation.  This flag
> check ensures that those parts reset without needlessly alarming the
> user.  Other unexpected resets by other parts will dump debug info
> and message the reset action to the user, as originally intended.
> 
> Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
> Acked-by: Bruce Allan <bruce.w.allan@intel.com>
> Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
