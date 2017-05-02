From: Miroslav Lichvar <mlichvar@redhat.com>
Subject: Re: [PATCH v2 net-next 0/7] Extend socket timestamping API
Date: Tue, 2 May 2017 14:55:01 +0200
Message-ID: <20170502125501.GC4610@localhost>
References: <20170502101103.30444-1-mlichvar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Richard Cochran <richardcochran@gmail.com>,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31677 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750934AbdEBMzE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 2 May 2017 08:55:04 -0400
Content-Disposition: inline
In-Reply-To: <20170502101103.30444-1-mlichvar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hm, I see that net-next was closed. I missed the annoucement. Sorry
for the spam.

On Tue, May 02, 2017 at 02:46:02PM +0200, Miroslav Lichvar wrote:
> Changes v1->v2:
> - added separate patch for new NAPI functions 
> - split code from __sock_recv_timestamp() for better readability
> - fixed RCU locking
> - fixed compiler warning (missing case in switch in first patch)
> - inline sw_tx_timestamp() in its only user

-- 
Miroslav Lichvar
