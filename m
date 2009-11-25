From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: convert /proc/net/rt_acct to seq_file
Date: Wed, 25 Nov 2009 15:40:44 -0800 (PST)
Message-ID: <20091125.154044.156172032.davem@davemloft.net>
References: <20091125074547.GA3467@x200.malnet.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40765
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S935205AbZKYXkZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 18:40:25 -0500
In-Reply-To: <20091125074547.GA3467@x200.malnet.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 25 Nov 2009 10:45:47 +0300

> Rewrite statistics accumulation to be in terms of structure fields,
> not raw u32 additions. Keep them in same order, though.
> 
> This is the last user of create_proc_read_entry() in net/,
> please NAK all new ones as well as all new ->write_proc, ->read_proc and
> create_proc_entry() users. Cc me if there are problems. :-)
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied, thanks Alexey.
