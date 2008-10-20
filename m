From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i
	cannot navigate
Date: Mon, 20 Oct 2008 22:51:44 +0200
Message-ID: <20081020205144.GA2837@ami.dom.local>
References: <bug-11721-11547@http.bugzilla.kernel.org/> <20081020154737.2D0CA108042@picon.linux-foundation.org> <20081020171530.GA2564@ami.dom.local> <20081020214818.09d88b48@topolino>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>
To: Aldo Maggi <sentiniate@tiscali.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:48692 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbYJTUvy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 16:51:54 -0400
Received: by ey-out-2122.google.com with SMTP id 6so648206eyi.37
        for <netdev@vger.kernel.org>; Mon, 20 Oct 2008 13:51:52 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081020214818.09d88b48@topolino>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 20, 2008 at 09:48:18PM +0200, Aldo Maggi wrote:
...
> moreover, i read more carefully what you and Jarek wrote above, please let me
> know if you deem still necessary that i apply the patch you provided and
> compile or if you like i compile the latest kernel or whatever.

Aldo, my advice, in case Ilpo is busy now:

Since it looks like the problem/bug isn't in the kernel, but rather
somewhere in between (router, modem etc.) which is mislead by changed
(compared to 2.6.26) order of tcp options, I doubt Ilpo needs now
these dumps so much: it should be enough to say works or doesn't work.

You have checked it works in 2 cases (without tcp_sack, and without
tcp_timestamp) when mss is the first option again. With Ilpo's patch
these two options could be still present, and mss at the beginning.
It should work because it's like 2.6.26 did this, but I think, it
would be nice to check this anyway, if it's not a problem. Then
trying the latest kernel (at least 2.6.27) with this patch should be
most useful.

Thanks,
Jarek P.
