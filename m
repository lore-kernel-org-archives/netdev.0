From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] SCTP: fix wrong debug counting of datamsg
Date: Thu, 10 Apr 2008 01:57:47 -0700 (PDT)
Message-ID: <20080410.015747.65169066.davem@davemloft.net>
References: <47F1AEDB.1080300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, lksctp-developers@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: lizf@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41065
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751649AbYDJI5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2008 04:57:48 -0400
In-Reply-To: <47F1AEDB.1080300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Zefan <lizf@cn.fujitsu.com>
Date: Tue, 01 Apr 2008 11:41:15 +0800

> Should not count it if the allocation of this object
> failed.
> 
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

This is a bug fix, but for a debugging feature, so I
have applied it to net-2.6.26
