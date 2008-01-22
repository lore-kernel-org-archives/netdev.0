From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: sky2: call sky2_set_multicast from sky2_restart?
Date: Mon, 21 Jan 2008 20:02:43 -0800
Message-ID: <20080121200243.1a0a1828@speedy>
References: <671c20540801181120i55bd8ff0r8385636d1ce5b2e@mail.gmail.com>
	<671c20540801181130w4ec704acu42a89a78e8b84cb3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Tom Burns" <tom.i.burns@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:40394 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752766AbYAVECs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 23:02:48 -0500
In-Reply-To: <671c20540801181130w4ec704acu42a89a78e8b84cb3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Jan 2008 14:30:52 -0500
"Tom Burns" <tom.i.burns@gmail.com> wrote:

> Hi List,
> 
> Throughout the sky2.c file any call to sky2_up(dev) is followed (soon
> enough) by a call to sky2_set_multicast(dev).  Should this not also be
> the case when it is called in sky2_restart()?
> 
> Cheers,
> Tom Burns
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

It probably should be done, but not worth forcing into 2.6.24 at this late date.
