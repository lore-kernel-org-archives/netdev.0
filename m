From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] net-timestamp: Make the clone operation
 stand-alone from phy timestamping
Date: Thu, 04 Sep 2014 09:44:47 -0700
Message-ID: <1409849087.26422.124.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140904161314.6883.22217.stgit@ahduyck-bv4.jf.intel.com>
	 <20140904162039.6883.39277.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	davem@davemloft.net, willemb@google.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35475 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbaIDQou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 12:44:50 -0400
Received: by mail-pa0-f42.google.com with SMTP id lf10so20452729pab.15
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 09:44:50 -0700 (PDT)
In-Reply-To: <20140904162039.6883.39277.stgit@ahduyck-bv4.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-04 at 12:21 -0400, Alexander Duyck wrote:

> In addition I have added a destructor named sock_efree which is meant to
> provide a simple way for dropping the reference to skb exceptions that
> aren't part of either the receive or send windows for the socket, and I
> have removed some duplication in spots where this destructor could be used
> in place of sock_edemux.

This is an interesting idea but belongs to a separate patch ?
