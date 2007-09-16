From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH for 2.6.24] SCTP: Implement the Supported Extensions
 Parameter
Date: Sun, 16 Sep 2007 15:55:31 -0700 (PDT)
Message-ID: <20070916.155531.42781343.davem@davemloft.net>
References: <11897091493925-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:53480
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753532AbXIPWzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 18:55:36 -0400
In-Reply-To: <11897091493925-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu, 13 Sep 2007 14:45:49 -0400

> [... i can't seem to spell to save my life lately...]
> 
> SCTP Supported Extenions parameter is specified in Section 4.2.7
> of the ADD-IP draft (soon to be RFC).  The parameter is
> encoded as:
> 
>       0                   1                   2                   3
>       0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
>      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>      |     Parameter Type = 0x8008   |      Parameter Length         |
>      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>      | CHUNK TYPE 1  |  CHUNK TYPE 2 |  CHUNK TYPE 3 |  CHUNK TYPE 4 |
>      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>      |                             ....                              |
>      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
>      | CHUNK TYPE N  |      PAD      |      PAD      |      PAD      |
>      +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
> 
> It contains a list of chunks that a particular SCTP extension
> uses.  Current extensions supported are Partial Reliability
> (FWD-TSN) and ADD-IP (ASCONF and ASCONF-ACK).
> 
> When implementing new extensions (AUTH, PKT-DROP, etc..), new
> chunks need to be added to this parameter.  Parameter processing
> would be modified to negotiate support for these new features.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6.24, thanks Vlad.
