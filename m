From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sctp: dubious bitfields in sctp_transport
Date: Wed, 26 May 2010 00:40:20 -0700 (PDT)
Message-ID: <20100526.004020.59666337.davem@davemloft.net>
References: <20100522202024.GL22515@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, yjwei@cn.fujitsu.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46807
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751377Ab0EZHkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 03:40:10 -0400
In-Reply-To: <20100522202024.GL22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 22 May 2010 22:20:24 +0200

> Sparse complains because these one-bit bitfields are signed.
>   include/net/sctp/structs.h:879:24: error: dubious one-bit signed bitfield
>   include/net/sctp/structs.h:889:31: error: dubious one-bit signed bitfield
>   include/net/sctp/structs.h:895:26: error: dubious one-bit signed bitfield
>   include/net/sctp/structs.h:898:31: error: dubious one-bit signed bitfield
>   include/net/sctp/structs.h:901:27: error: dubious one-bit signed bitfield
> 
> It doesn't cause a problem in the current code, but it would be better
> to clean it up.  This was introduced by c0058a35aacc7: "sctp: Save some
> room in the sctp_transport by using bitfields".
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
