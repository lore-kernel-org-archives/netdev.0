From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/5] NETDEV: Wait for autoconfigurable network devices
 to become available
Date: Wed, 29 Apr 2009 17:21:00 -0700 (PDT)
Message-ID: <20090429.172100.152526095.davem@davemloft.net>
References: <20090430001153.GA3751@cuplxvomd02.corp.sa.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: dvomlehn@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38064
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752668AbZD3AVI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 20:21:08 -0400
In-Reply-To: <20090430001153.GA3751@cuplxvomd02.corp.sa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This have_all_netdevs() will never return true unless the user
specifies a specific device name.
