From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] net: move trie_local and trie_main into the
 proc iterator
Date: Fri, 07 Dec 2007 00:48:11 -0800 (PST)
Message-ID: <20071207.004811.07703526.davem@davemloft.net>
References: <20071206150012.GA22475@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, devel@openvz.org,
	netdev@vger.kernel.org, ebiederm@xmission.com
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751967AbXLGIsN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2007 03:48:13 -0500
In-Reply-To: <20071206150012.GA22475@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 6 Dec 2007 18:00:12 +0300

> From: Eric W. Biederman <ebiederm@xmission.com>
> 
> We only use these variables when displaying the trie in proc so
> place them into the iterator to make this explicit.  We should
> probably do something smarter to handle the CONFIG_IP_MULTIPLE_TABLES
> case but at least this makes it clear that the silliness is limited
> to the display in /proc.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied.
