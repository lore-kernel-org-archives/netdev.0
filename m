From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH NEXT 1/1] net: create num frags requested
Date: Fri, 29 Apr 2011 11:37:51 -0700 (PDT)
Message-ID: <20110429.113751.246525196.davem@davemloft.net>
References: <1303525340-29483-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42781
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753979Ab1D2SiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2011 14:38:24 -0400
In-Reply-To: <1303525340-29483-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Date: Fri, 22 Apr 2011 19:22:20 -0700

> Pktgen doesn't generate number of frags requested.
> Divide packet size by number of frags and fill that in every frags.
> 
> Example:
> With packet size 1470, it generate only 11 frags. Initial frags
> get lenght 706, 353, 177....so on. Last frag get divided by 2.
> 
> Now with this fix, each frags will get 78 bytes.
> 
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Applied, thanks.
