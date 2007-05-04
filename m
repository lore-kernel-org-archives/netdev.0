From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/4] [SCTP] Fix the SO_REUSEADDR handling to be similar
 to TCP
Date: Fri, 04 May 2007 13:34:57 -0700 (PDT)
Message-ID: <20070504.133457.84976510.davem@davemloft.net>
References: <1178310175881-git-send-email-vladislav.yasevich@hp.com>
	<11783101751746-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031545AbXEDUez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 16:34:55 -0400
In-Reply-To: <11783101751746-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  4 May 2007 16:22:53 -0400

> Update the SO_REUSEADDR handling to also check for listen state.  This
> was muliple listening server sockets can't be created and they will
> not steal packets from each other.
> Reported by Paolo Galtieri <pgaltieri@mvista.com>
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
