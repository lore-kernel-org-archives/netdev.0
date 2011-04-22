From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: increment work_counter in be_worker
Date: Thu, 21 Apr 2011 17:36:15 -0700 (PDT)
Message-ID: <20110421.173615.232758721.davem@davemloft.net>
References: <1303381204-31258-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53298
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753960Ab1DVAgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2011 20:36:49 -0400
In-Reply-To: <1303381204-31258-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Thu, 21 Apr 2011 12:20:04 +0200

> The commit 609ff3b adds support to display temperature of ASIC but there
> is missing increment of work_counter in be_worker. Because of this 1) the
> function be_cmd_get_die_temperature is called every 1 second instead of
> every 32 seconds 2) be_cmd_get_die_temperature is called, although it is
> not supported.
> This patch fixes this bug.
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied to net-2.6, thank you.
