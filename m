From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCPCT+1: initial SYN exchange with SYNACK data
Date: Mon, 05 Oct 2009 01:06:30 -0700 (PDT)
Message-ID: <20091005.010630.214808506.davem@davemloft.net>
References: <4AC79905.1030904@gmail.com>
	<20091005.002719.146534039.davem@davemloft.net>
	<4AC9A714.7060903@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: william.allen.simpson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49742
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758539AbZJEIGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 04:06:37 -0400
In-Reply-To: <4AC9A714.7060903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: William Allen Simpson <william.allen.simpson@gmail.com>
Date: Mon, 05 Oct 2009 03:58:12 -0400

> I see we're cross-posting at the same time....  Since in your previous
> review (last year) this issue was not mentioned, is there some other
> data organization that you would suggest?
> 
> http://article.gmane.org/gmane.linux.network/102779
> 
>   "This looks mostly fine to me.  I would even advocate not using a
>   config
>    option for this."

I'm looking at the patch more closely, and as I learn more
things about your change, my position changes.

> Perhaps you would prefer this as a config option after all?

No, then nobody is going to deploy this thing (meaning it really will
be useless), or everyone will and everyone will enable it and thus eat
the space.

It's bad either way.

Store the data either somewhere else or in an extremely compact form.
