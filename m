From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: fix crash during module unload
Date: Mon, 02 Mar 2009 22:29:01 -0800 (PST)
Message-ID: <20090302.222901.66420231.davem@davemloft.net>
References: <1236012411-17841-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35307
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbZCCG3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 01:29:20 -0500
In-Reply-To: <1236012411-17841-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon,  2 Mar 2009 11:46:50 -0500

> An extra list_del() during the module load failure and unload
> resulted in a crash with a list corruption.  Now sctp can
> be unloaded again.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
