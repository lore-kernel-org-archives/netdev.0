From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: XFRM: Could we change ESP padding?
Date: Mon, 17 Dec 2012 08:25:44 +0100
Message-ID: <20121217072544.GL18940@secunet.com>
References: <CAJFZqHzDDtUacnQzd-gcS8JBvPdgspozWkUFOogS4nDmvZz7rg@mail.gmail.com>
 <20121217064302.GK18940@secunet.com>
 <CAJFZqHzCEJyvxc2NNh3_U8oT9Uh94N6EXLb4UA=twvVcVnEd5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: RongQing Li <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43695 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813Ab2LQHZr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Dec 2012 02:25:47 -0500
Content-Disposition: inline
In-Reply-To: <CAJFZqHzCEJyvxc2NNh3_U8oT9Uh94N6EXLb4UA=twvVcVnEd5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 17, 2012 at 02:56:47PM +0800, RongQing Li wrote:
> 2012/12/17 Steffen Klassert <steffen.klassert@secunet.com>:
> >
> > RFC 4303 says that the receiver should inspect the padding field,
> > so we are free to do it or not. You can find a comment that explains
> > why we don't do it in the esp_input_done2() function ;-)
> >
> Thanks.
> 
> But I see BSD has implemented it, and cisco device has similar implmentation.
> 

The comment at the place where the padding field inspection should be done
is rather old. I always respected this when I came accross this code, but
I would not mind to have it implemented. Not sure if somebody still
remembers exactly why it was not implemented.
