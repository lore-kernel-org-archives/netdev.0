From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: CodingStyle: while ((a=b))
Date: Sun, 27 Jun 2004 00:07:08 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406270407.i5R4763K011324@ginger.cmf.nrl.navy.mil>
References: <20040627012504.GB14444@taniwha.stupidest.org>
Reply-To: chas3@users.sourceforge.net
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org,
        netdev@oss.sgi.com, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wedgwood <cw@f00f.org>
In-reply-to: Your message of "Sat, 26 Jun 2004 18:25:04 PDT."
             <20040627012504.GB14444@taniwha.stupidest.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20040627012504.GB14444@taniwha.stupidest.org>,Chris Wedgwood writes:
>I'm not sure this has ever been a problem in the past has it?

as a counter example, tired eyes (and the compiler!) cant tell
the difference between:

	while ((a = b))
	if ((a = b))

and

	while ((a == b))
	if ((a == b))

so i just tend to shy away from assignments in conditions.
