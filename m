From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] Implementation of RFC 4898 Extended TCP
 Statistics (Web10G)
Date: Tue, 16 Dec 2014 14:33:32 -0800
Message-ID: <1418769212.9773.65.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54908FAD.5060500@psc.edu>
		<20141216.150354.64901094367530710.davem@davemloft.net>
		<54909278.6090806@psc.edu>
	 <20141216.151823.2276708539799601894.davem@davemloft.net>
	 <54909DD5.5070202@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org
To: rapier <rapier@psc.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:51394 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751047AbaLPWde (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 17:33:34 -0500
Received: by mail-ig0-f173.google.com with SMTP id r2so7752127igi.6
        for <netdev@vger.kernel.org>; Tue, 16 Dec 2014 14:33:34 -0800 (PST)
In-Reply-To: <54909DD5.5070202@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-12-16 at 16:02 -0500, rapier wrote:

> I understand where you are coming from. I do believe that our 
> methodology provides some advantages over a tcp_info solution. I'll 
> provide some information on that tomorrow after I've had a chance to 
> talk about this in more depth with our dev team. That being said, we 
> only really care about the instrument set being incorporated as such we 
> will take a closer look tcp_info shortly.

Hmm...

There is very little chance web10g ~3000 lines of code are added into
linux TCP stack, by people who did not submit netdev changes in last
years.

At Google, we tried the web10g route, but reverted it (today !) in favor
of tcp_info extensions (ss command from iproute2 can also grab/display
these), after too many bugs being filled.

Researchers love/want to have hundred of metrics. This does not mean
linux has to provide them natively, unless we can prove it is really
damn useful.

Sorry, but someone had to raise some reality concerns.

tcp_info _is_ extensible, granted you do not try to push 127 new metrics
in it.

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=977cb0ecf82eb6d15562573c31edebf90db35163
