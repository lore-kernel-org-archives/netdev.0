From: David Miller <davem@davemloft.net>
Subject: Re: [patch] sctp: fix test for end of loop
Date: Wed, 08 Sep 2010 13:30:45 -0700 (PDT)
Message-ID: <20100908.133045.245384362.davem@davemloft.net>
References: <20100906122344.GA2764@bicker>
	<4C87F185.3070402@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, sri@us.ibm.com, yjwei@cn.fujitsu.com,
	cascardo@holoscopio.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58967
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753674Ab0IHUa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:30:28 -0400
In-Reply-To: <4C87F185.3070402@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 08 Sep 2010 16:26:45 -0400

> I am really not fond of this code.  I think it would be better to move
> this abort code into the loop and break out once things are aborted.
> 
> This way we can get rid of the whole found check after the outer loop happens
> and it cleans things up nicely.

Vlad see my followup.
