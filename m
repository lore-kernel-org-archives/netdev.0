From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 1/3] Open out the check for Nagle
Date: Mon, 21 Jul 2014 16:25:37 -0700 (PDT)
Message-ID: <20140721.162537.1473346987310446422.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D17278F4D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048AbaGUXhP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 19:37:15 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17278F4D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Fri, 18 Jul 2014 17:36:24 +0000

> The check for Nagle contains 6 separate checks all of which must be true
> before a data packet is delayed.
> Separate out each into its own 'if (test) return SCTP_XMIT_OK' so that
> the reasons can be individually described.
> 
> Also return directly with SCTP_XMIT_RWND_FULL.
> Delete the now-unused 'retval' variable and 'finish' label from
> sctp_packet_can_append_data().
> 
> Signed-off-by: David Laight <david.laight@aculab.com>

Please add the "sctp: " subsystem prefix to this subject line.
