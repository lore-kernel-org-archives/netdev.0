From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/15] [ATM]: Use proc_create() to setup ->proc_fops
 first
Date: Thu, 28 Feb 2008 13:56:11 -0800 (PST)
Message-ID: <20080228.135611.252555298.davem@davemloft.net>
References: <47C6931B.70204@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60177
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752136AbYB1V4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:56:12 -0500
In-Reply-To: <47C6931B.70204@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:55:23 +0800

> Use proc_create() to make sure that ->proc_fops be setup before gluing
> PDE to main tree.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks.

Some of those paths could definitely use some error
handling.
