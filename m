From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Demonstration code on how to trigger tcp6_sock leak
Date: Sun, 25 Jan 2004 14:25:26 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040125.142526.69342105.yoshfuji@linux-ipv6.org>
References: <20040124131307.GB2666@bender.home.hensema.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, usagi-core@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: erik@hensema.net
In-Reply-To: <20040124131307.GB2666@bender.home.hensema.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040124131307.GB2666@bender.home.hensema.net> (at Sat, 24 Jan 2004 14:13:07 +0100), Erik Hensema <erik@hensema.net> says:

> I wrote some quick&dirty code showing the tcp6_sock leak in Linux 2.6.x.
> The server part listens for incoming connections and accept()'s them. The
> client will simply connect() to the server and close the connection.

Okay, I confirm that there're something wrong with tcp6 socket.
I'll look into it as soon as possible.

--yoshfuji
