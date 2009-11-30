From: David Miller <davem@davemloft.net>
Subject: Re: [patch] drop chan->wsem on error path
Date: Mon, 30 Nov 2009 00:07:04 -0800 (PST)
Message-ID: <20091130.000704.11881105.davem@davemloft.net>
References: <20091129160255.GN10640@bicker>
	<20091130074418.GC25334@fi.muni.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, netdev@vger.kernel.org
To: kas@fi.muni.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37031
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751943AbZK3IG6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 03:06:58 -0500
In-Reply-To: <20091130074418.GC25334@fi.muni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Kasprzak <kas@fi.muni.cz>
Date: Mon, 30 Nov 2009 08:44:18 +0100

> Dan Carpenter wrote:
> : The other paths all drop chan->wsem.  This was found by a static
> : checker (smatch).
> 
> 	You are right, thanks!
> 
> : 
> : Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> Acked-by: Jan "Yenya" Kasprzak <kas@fi.muni.cz>

Patch applied, thanks everyone.
