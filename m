From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Sat, 4 Oct 2008 22:09:39 +0200
Message-ID: <20081004200939.GB15152@ami.dom.local>
References: <20081002194845.GB2664@ami.dom.local> <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local> <1223145027.23358.20.camel@f6bvp-5> <20081004191114.GA15152@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: "Bernard, f6bvp" <f6bvp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.185]:12187 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbYJDUDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2008 16:03:39 -0400
Received: by nf-out-0910.google.com with SMTP id d3so816612nfc.21
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2008 13:03:36 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081004191114.GA15152@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 04, 2008 at 09:11:14PM +0200, Jarek Poplawski wrote:
...
> BTW, I think there is an additional, not serious problem with freeing
> unorphaned sockets by netrom (as seen in your debugging logs with non
> zero in the 2-nd, and 6 in the 3-rd column). So, it would be nice to
> check if my #4 patch could help for this. (You need then 2.6.27-rc
> with patches #1(debugging), #3, #4 as signed in my previous message,
> and of course above mentioned one reverted).

BTW, could you please test it with and without the #4 (af_netrom) patch?

Jarek P.
