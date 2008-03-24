From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP]: Remove redundant wrapper functions.
Date: Sun, 23 Mar 2008 22:46:50 -0700 (PDT)
Message-ID: <20080323.224650.188512602.davem@davemloft.net>
References: <1206016032-13386-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37375
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754283AbYCXFqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2008 01:46:50 -0400
In-Reply-To: <1206016032-13386-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 20 Mar 2008 13:27:12 +0100

> sctp_datamsg_free and sctp_datamsg_track are just aliases for
> sctp_datamsg_put and sctp_chunk_hold, respectively.
> 
> Saves 32 Bytes on x86.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied.
