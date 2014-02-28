From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP: Support configurable delayed-ack parameters
Date: Fri, 28 Feb 2014 08:52:24 -0800
Message-ID: <1393606344.26794.68.camel@edumazet-glaptop2.roam.corp.google.com>
References: <00e801cf3497$c37255f0$4a5701d0$@codeaurora.org>
	 <1393602573.26794.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5310BB56.6060208@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Harout Hedeshian <harouth@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:44670 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752780AbaB1Qw0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Feb 2014 11:52:26 -0500
Received: by mail-pd0-f175.google.com with SMTP id x10so953243pdj.34
        for <netdev@vger.kernel.org>; Fri, 28 Feb 2014 08:52:26 -0800 (PST)
In-Reply-To: <5310BB56.6060208@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-02-28 at 09:37 -0700, Harout Hedeshian wrote:
> 
> Hi Eric,
> 
> Disclaimer before I waste peoples' time on a ghost chase: This is
> running on non-x86 custom hardware where there may be buggy drivers or
> implementation. Also, 
> we are running on 3.10.0 and are unable to move to a newer kernel for
> reasons beyond my control.
> 
> I will capture pcap logs showing the TCP stream under standard
> configuration, and with mss*4. That said, sharing will be a problem as
> these files even with 
> limited capture size can be several hundred MB (of course attaching to
> the email won't work).
> 
Maybe you can point the relevant part, and shrink the pcap to reasonable
sizes ?

> I will keep an eye out for the should_defer() patch today. I would
> also appreciate if you could point me to the TCP Small Queue patch. I
> would like to pull 
> these into my build and give them a shot.

Please note it was a shout in the dark :)

Anyway here is the patch :
http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=bf06200e732de613a1277984bf34d1a21c2de03d
