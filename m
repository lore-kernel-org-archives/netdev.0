From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: CodingStyle: while ((a=b))
Date: Sat, 26 Jun 2004 21:20:20 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406270120.i5R1KJiN010390@ginger.cmf.nrl.navy.mil>
References: <cw@f00f.org>
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org,
        netdev@oss.sgi.com, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wedgwood <cw@f00f.org>
In-Reply-To: Message from Chris Wedgwood <cw@f00f.org>
   of "Sat, 26 Jun 2004 16:42:21 PDT." <20040626234221.GB12761@taniwha.stupidest.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20040626234221.GB12761@taniwha.stupidest.org>,Chris Wedgwood writes
:
>    while ((a=b)) to while ((a=b) != 0)

adding the != does not make the conditional clearer to me.  in fact
it just make it harder to read.  however, it probably not a good
idea to do assignments in places where someone might not expect to
see them.  the alternative something like this:

	while (1) {
		a = b;
		if (a == 0)
			break;
	}

but its not very pretty either.
