From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/3] sctp: update SNMP statiscts when T5 timer
 expired.
Date: Thu, 09 Oct 2008 14:33:34 -0700 (PDT)
Message-ID: <20081009.143334.141756059.davem@davemloft.net>
References: <1223558975-1550-1-git-send-email-vladislav.yasevich@hp.com>
	<1223558975-1550-5-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47441
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754024AbYJIVd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:33:58 -0400
In-Reply-To: <1223558975-1550-5-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu,  9 Oct 2008 09:29:35 -0400

> The T5 timer is the timer for the over-all shutdown procedure.  If
> this timer expires, then shutdown procedure has not completed and we
> ABORT the association.  We should update SCTP_MIB_ABORTED and
> SCTP_MIB_CURRESTAB  when aborting.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Also applied, thanks.
