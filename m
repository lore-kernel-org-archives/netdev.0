From: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Subject: Re: TCP default congestion control in linux should be newreno
Date: Thu, 4 Dec 2008 21:05:37 +0100
Message-ID: <b98e548c0812041205y4538b62apbbdb42469220ffa9@mail.gmail.com>
References: <20081204185022.6108d19e@gmail.com>
	 <20081204.101805.45306327.davem@davemloft.net>
	 <b98e548c0812041105o6c2ded8br3c2349cabceaf99f@mail.gmail.com>
	 <20081204.115416.174997306.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: ldecicco@gmail.com, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.187]:12830 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753091AbYLDUFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2008 15:05:39 -0500
Received: by gv-out-0910.google.com with SMTP id e6so881677gvc.37
        for <netdev@vger.kernel.org>; Thu, 04 Dec 2008 12:05:37 -0800 (PST)
In-Reply-To: <20081204.115416.174997306.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> The bigger problem is that windows are so much larger now that going
> back to the stone ages and newreno recovery behavior is absolutely not
> an option any more.

average window cannot be much larger, because average windows  follow
network capacity in any case. so you can end up having only more
oscillating windows (i.e. more timeouts, more retransmissions)

>
> So "go back to newreno" is not a suggestion to be taken seriously.

this should be supported by experiments. i do not think reno is stone
age, i think is very close to the optimal you can get given the
feedback available in current nets.

you should show less timeouts, less retransmissions larger goodput
when using a rocket tcp.

-s
