From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [Fwd: [PATCH net 0/1] af_iucv: Validate socket address length in
 iucv_sock_bind()]
Date: Wed, 20 Jan 2016 10:33:04 +0100
Message-ID: <1453282384.13456.4.camel@BR9GV9YG.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ubraun@linux.vnet.ibm.com, ursula.braun@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp05.uk.ibm.com ([195.75.94.101]:38360 "EHLO
	e06smtp05.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933783AbcATJdK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 04:33:10 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 20 Jan 2016 09:33:08 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thx, Dave! "net" and "stable" are exactly my intended trees for this
patch. "next-tree" has been my spelling error; I meant "net-tree". Sorry
for that!

-------- Forwarded Message --------
> From:        David Miller <davem@davemloft.net>
> To:        ubraun@linux.vnet.ibm.com,
> Cc:        mschwid2@linux.vnet.ibm.com, heicars2@linux.vnet.ibm.com,
> netdev@vger.kernel.org, linux-s390@vger.kernel.org,
> ubraunu@linux.vnet.ibm.com
> Date:        19/01/2016 20:24
> Subject:        Re: [PATCH net 0/1] af_iucv: Validate socket address
> length in iucv_sock_bind()
> Sent by:        linux-s390-owner@vger.kernel.org
> 
> ______________________________________________________________________
> 
> 
> 
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Tue, 19 Jan 2016 10:41:32 +0100
> 
> > this patch fixes a problem reported by Dmitry Vyukov in december. It
> is built
> > and intended for the next-tree.
> 
> A bug fix is not appropriate for the next tree.
> 
> All bug fixes should target 'net'.  You even contacted me privately
> asking me to queue this up for -stable.  Submitting something for
> net-next and wanting a -stable backport is doubly inappropriate.
> 
> Things don't go to -stable unless it's in Linus's tree.  'net' is
> for bug fixes, 'net-next' (closed right now) is for new features,
> cleanups, and fixes to code only present in 'net-next'.
> 
> Anyways I applied this to 'net' and queued it up for -stable.
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-s390"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
