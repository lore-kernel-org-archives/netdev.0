From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-26] cxgb4vf: fix mailbox data/control coherency
 domain race
Date: Mon, 10 Jan 2011 13:56:38 -0800 (PST)
Message-ID: <20110110.135638.267960720.davem@davemloft.net>
References: <1294696261-21209-1-git-send-email-leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53632
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754657Ab1AJV4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 16:56:05 -0500
In-Reply-To: <1294696261-21209-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Mon, 10 Jan 2011 13:51:01 -0800

> For the VFs, the Mailbox Data "registers" are actually backed by
> T4's "MA" interface rather than PL Registers (as is the case for
> the PFs).  Because these are in different coherency domains, the
> write to the VF's PL-register-backed Mailbox Control can race in
> front of the writes to the MA-backed VF Mailbox Data "registers".
> So we need to do a read-back on at least one byte of the VF Mailbox
> Data registers before doing the write to the VF Mailbox Control
> register.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

Applied, thanks.
