From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: 2.6.0-test9 : bridge freezes
Date: Sat, 22 Nov 2003 08:20:40 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0311220819260.2379-100000@home.osdl.org>
References: <200311221527.UAA29684@eis.iisc.ernet.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: SVR Anand <anand@eis.iisc.ernet.in>
In-Reply-To: <200311221527.UAA29684@eis.iisc.ernet.in>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Sat, 22 Nov 2003, SVR Anand wrote:
> 
> The problem is : After 3 to 4 hours of functioning, the bridge stops working 
> and the machine becomes unusable where it doesn't respond to keyboard, and 
> there is no video display.

Sounds like a memory leak somewhere. It would probably be interesting to 
watch /proc/slabinfo every five minutes or so, and see what happens..

		Linus
