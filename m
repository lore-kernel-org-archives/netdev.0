From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 net-next] cnic: Fix interrupt logic
Date: Wed, 08 Jun 2011 23:52:55 -0700 (PDT)
Message-ID: <20110608.235255.348627008657936656.davem@davemloft.net>
References: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751419Ab1FIGw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 02:52:56 -0400
In-Reply-To: <1307597376-5379-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Wed, 8 Jun 2011 22:29:32 -0700

> We need to keep looping until cnic_get_kcqes() returns 0.  cnic_get_kcqes()
> returns a maximum of 64 entries.  If there are more entries in the queue
> and we don't loop back, the remaining entries may not be serviced for a
> long time.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
