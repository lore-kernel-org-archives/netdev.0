From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] be2net: get rid of be_ctrl_info struct/abstraction
Date: Sat, 01 Aug 2009 23:07:42 -0700 (PDT)
Message-ID: <20090801.230742.07669593.davem@davemloft.net>
References: <20090728084408.GA4409@serverengines.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathyap@serverengines.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41246
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbZHBGHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 02:07:34 -0400
In-Reply-To: <20090728084408.GA4409@serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathyap@serverengines.com>
Date: Tue, 28 Jul 2009 14:14:08 +0530

> Currently only the be_ctrl_info struct ptr (instead of adapter) is
>  passed to all the routines in be_cmds.c. Instead pass be_adapter
> ptr to allow access to all its fields. Merge the contents of struct be_ctrl_info
> into be_adapter. The resulting code is simpler.
> 
> Signed-off-by: Sathya Perla <sathyap@serverengines.com>

Applied.
