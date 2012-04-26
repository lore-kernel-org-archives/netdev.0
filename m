From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] allow skb->head to point/alias to first skb frag
Date: Thu, 26 Apr 2012 22:18:34 +0200
Message-ID: <1335471514.2775.66.camel@edumazet-glaptop>
References: <CANP3RGdnZk5b-gMkF8BPScrp9xos4X1u3n58ocuBQhTT7taE8A@mail.gmail.com>
	 <1335443554.2775.33.camel@edumazet-glaptop>
	 <1335448252.2775.41.camel@edumazet-glaptop>
	 <20120426.161221.923108657396544878.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, ilpo.jarvinen@helsinki.fi, rick.jones2@hp.com,
	netdev@vger.kernel.org, therbert@google.com, ncardwell@google.com,
	ycheng@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:32914 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208Ab2DZUSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 16:18:43 -0400
Received: by wibhr17 with SMTP id hr17so5733324wib.1
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 13:18:41 -0700 (PDT)
In-Reply-To: <20120426.161221.923108657396544878.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-26 at 16:12 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 26 Apr 2012 15:50:52 +0200
> 
> > Here is the raw patch. (tg3 part is dirty and needs some helpers)
> > 
> > I am working on the TCP coalesce part, the splice() helpers (to avoid a
> > copy), and split in five different patches for further
> > discussion/inclusion.
> 
> Ok, I like it.
> 
> I was confused into thinking that you were going to put this head page
> into skb_shared_info()'s page vector.  But you're not.
> 

Well, my first mail was confuse... it was just an idea without prior
thinking. Now the picture is clear.

Thanks
