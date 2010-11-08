From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: Using Netfiletr hooks without IP stack
Date: Mon, 8 Nov 2010 21:23:48 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1011082114210.2608@obet.zrqbmnf.qr>
References: <A50724DAD8873141837C64A73A73735F052DD9@mailesl2.esl.corp.elbit.co.il>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Netfilter Developer Mailing List
	<netfilter-devel@vger.kernel.org>, netdev@vger.kernel.org
To: Yedidia Amit <amit.yedidia@elbitsystems.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <A50724DAD8873141837C64A73A73735F052DD9@mailesl2.esl.corp.elbit.co.il>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 2010-11-08 07:32, Yedidia Amit wrote:

>Hi All,
>
>I want to use the netfilter framework on my system (running linux
>2.6.33)
>My purpose is to capture and manipulate IP packets. The catch is that I
>am working without the IP stack, so I need to capture the packets in the
>Ethernet layer.  I have BSD sockets but the TCP/IP is removed from the
>menuconfig
>
>Are there any hooks which are available for me on that level, or should
>I add some new ones?

That would leave you with af_packet (only).


-- 
By replying, your organization agrees to relinquish control over future 
messages posted in public places such as these, and grant everybody a 
worldwide irrevocable right to do with it however they please. The right 
to claim sending in error is waived. If you don't accept these terms, 
don't post.
