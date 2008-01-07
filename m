From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] [SCTP]: Correctly handle AUTH parameters in
 unexpected INIT
Date: Mon, 07 Jan 2008 00:27:53 -0800 (PST)
Message-ID: <20080107.002753.188675425.davem@davemloft.net>
References: <1199475946-11103-1-git-send-email-vladislav.yasevich@hp.com>
	<1199475946-11103-3-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47125
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754620AbYAGI1x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2008 03:27:53 -0500
In-Reply-To: <1199475946-11103-3-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  4 Jan 2008 14:45:45 -0500

> When processing an unexpected INIT chunk, we do not need to
> do any preservation of the old AUTH parameters.  In fact,
> doing such preservations will nullify AUTH and allow connection
> stealing.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
