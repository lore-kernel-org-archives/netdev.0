From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/15] [APPLETALK]: Use proc_create() to setup
 ->proc_fops first
Date: Thu, 28 Feb 2008 12:54:42 -0800 (PST)
Message-ID: <20080228.125442.189817178.davem@davemloft.net>
References: <47C692FB.9010201@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34260
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751438AbYB1Uym (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 15:54:42 -0500
In-Reply-To: <47C692FB.9010201@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Thu, 28 Feb 2008 18:54:51 +0800

> As Davem mentioned in his recently patch
> (d9595a7b9c777d45a74774f1428c263a0a47f4c0)
> that the procfs visibility should occur after
> the ->proc_fops are setup.
> 
> And also, Alexey provide proc_create() to make
> sure that ->proc_fops is setup before gluing PDE
> to main tree.
> 
> We use proc_create().
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied, thanks.
