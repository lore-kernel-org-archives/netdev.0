From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: Disable tcp MSS option in three way handshake?
Date: Sun, 4 Nov 2012 01:25:13 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1211040124370.30066@nerf07.vanv.qr>
References: <CAK3+h2xKHBNXzY0WNwPV+oGbY00UVfJpO-qjFW2cxCpmdt+hAg@mail.gmail.com> <1351204948.6537.263.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Vincent Li <vincent.mc.li@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:53324 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751184Ab2KDAZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2012 20:25:17 -0400
In-Reply-To: <1351204948.6537.263.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Friday 2012-10-26 00:42, Eric Dumazet wrote:
>On Thu, 2012-10-25 at 15:27 -0700, Vincent Li wrote:
>> 
>> this sounds crazy, we have a weird situation that an unknown tcp
>> implementation not putting tcp MSS option in the SYN/ACK which caused
>> us some issue. I am tasked to mimic the unknown tcp immplementation on
>> not sending MSS in tcp SYN/ACK, I am wondering if I can achieve that
>> by modifying linux kernel tcp code,  there is socket option
>> TCP_MAXSEG, but that seems only affecting the size of MSS, not
>> removing the MSS option. do you have any pointer on how to do that in
>> kernel tcp code?
>
>You'll have to patch the code.
>
>Or else, you could add a new feature to net/netfilter/xt_TCPMSS.c

Or you could just use -j TCPOPTSTRIP.
