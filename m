From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] hlist_for_each_entry_continue simplification
Date: Tue, 12 Feb 2008 17:26:56 -0800 (PST)
Message-ID: <20080212.172656.118569021.davem@davemloft.net>
References: <20080213005042.150212716@vyatta.com>
	<20080213005122.879352336@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@us.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36899
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762558AbYBMB0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2008 20:26:25 -0500
In-Reply-To: <20080213005122.879352336@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 12 Feb 2008 16:50:46 -0800

> All the users of hlist_for_each_entry_continue had to intialize pos
> before use; change API so pos is a pure temporary variable which matches
> the usage of other xxxx_for_each_entry routines.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

linux/list.h changes need to be reviewed on linux-kernel and
merged into Linus's tree via some means other than the
networking tree.

I just got chewed out for a similar issue wrt. the rcupdate.h
changes of yesterday and thus have to remove them from my
tree.
