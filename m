From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] [SCTP]: "list_for_each()" ->
 "list_for_each_entry()" where appropriate.
Date: Fri, 28 Mar 2008 16:32:18 -0700 (PDT)
Message-ID: <20080328.163218.258439481.davem@davemloft.net>
References: <1206716180-16573-1-git-send-email-vladislav.yasevich@hp.com>
	<1206716180-16573-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	rpjday@crashcourse.ca
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35491
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750793AbYC1XcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:32:25 -0400
In-Reply-To: <1206716180-16573-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 28 Mar 2008 10:56:17 -0400

> From: Robert P. J. Day <rpjday@crashcourse.ca>
> 
> Replacing (almost) all invocations of list_for_each() with
> list_for_each_entry() tightens up the code and allows for the deletion
> of numerous list iterator variables that are no longer necessary.
> 
> Signed-off-by: Robert P. J. Day <rpjday@crashcourse.ca>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

This is not a "bug fix", it's a huge cleanup and thus not appropriate
for 2.6.x

Please rebuild this patch series without this patch included,
you can submit it for 2.6.26

