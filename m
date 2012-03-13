From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: ip route show shows the routes in the inverse order?
Date: Mon, 12 Mar 2012 19:32:04 -0700
Message-ID: <20120312193204.5be5b4b8@nehalam.linuxnetplumber.net>
References: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Diego Woitasen <diego@woitasen.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51189 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751727Ab2CMCcI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2012 22:32:08 -0400
In-Reply-To: <CAA7Uhc=xFxiAc9ZL0KHQJ1Opr0m=Do_OuLmL7WWd7PU4JuUNnQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Mar 2012 22:18:48 -0300
Diego Woitasen <diego@woitasen.com.ar> wrote:

> Hi,
>  I've noticed that iproute and the old route command show the routes
> in the inverse order. This new behavior looks related to the removal
> of fib_hash (replaceed by fib_trie). I think that the old behavior
> should be recovered. More specific routes in the first place looks
> more natural for me and it's been the behavior for years. It doesn't
> make any sense to change it.
> 
>  Sorry if this was already discussed, I couldn't find anything in the archives.
> 
> Regards,
>  Diego
> 

The kerne never guaranteed any order in returned values. If you want a given
order than you need to sort them your self.
