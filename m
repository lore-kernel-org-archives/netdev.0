From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/8021q/vlanproc.c: fix check-after-use
Date: Tue, 14 Aug 2007 17:39:57 -0700 (PDT)
Message-ID: <20070814.173957.18578051.davem@davemloft.net>
References: <20070814212244.GB18945@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48612
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754632AbXHOAj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 20:39:57 -0400
In-Reply-To: <20070814212244.GB18945@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@kernel.org>
Date: Tue, 14 Aug 2007 23:22:44 +0200

> The Coverity checker spotted that we'd have already oops'ed if "vlandev"
> was NULL.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Fair enough, applied, thanks Adrian.
