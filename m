From: John Heffner <jheffner@psc.edu>
Subject: Re: 2.6.9 tcp problems
Date: Tue, 30 Nov 2004 10:44:43 -0500 (EST)
Message-ID: <Pine.LNX.4.58.0411301038150.14716@dexter.psc.edu>
References: <41AB6476.8060405@nea-fast.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kernel <kernel@nea-fast.com>
In-Reply-To: <41AB6476.8060405@nea-fast.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 29 Nov 2004, kernel wrote:

> I've run into a problem with 2.6.(8.1,9) after installing a secondary
> firewall. When I try to pull data through the original firewall (mail,
> http, ssh), it stops after approx. 260k. Running ethereal tells me "A
> segment before the frame was lost" followed by a bunch of  "This is a
> TCP duplicate ack" when using ssh. All 2.4.x machines and windows
> clients work fine. I built 2.4.28 and it works fine from my machine. I
> also fiddled with tcp_ecn and that didn't fix it either. I don't have
> any problems communicating to "local" machines. I've attached the
> tcpdump output from an scp attempt. NIC is a 3Com Corporation 3c905B.

Try `echo 0 > /proc/sys/net/ipv4/tcp_window_scaling'.  If this makes it
work, it's almost certainly a buggy firewall.

Also, tcpdumps are far more useful if they are binary (tcpdump -w) and
capture the beginning of the connection.

  -John
