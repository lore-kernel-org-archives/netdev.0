From: Chris Wedgwood <cw@f00f.org>
Subject: Re: CodingStyle: while ((a=b))
Date: Sat, 26 Jun 2004 18:25:04 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040627012504.GB14444@taniwha.stupidest.org>
References: <20040626234221.GB12761@taniwha.stupidest.org> <200406270120.i5R1KJiN010390@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, shemminger@osdl.org,
        netdev@oss.sgi.com, Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200406270120.i5R1KJiN010390@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 26, 2004 at 09:20:20PM -0400, chas williams (contractor) wrote:

> adding the != does not make the conditional clearer to me.  in fact
> it just make it harder to read.

so how about we stop merging these particular 'sparse cleanups' until
there is a consensus on how things should be done?

I'm no saying everyone should agree with me (even though you should)
just that consistency is good.

> however, it probably not a good idea to do assignments in places
> where someone might not expect to see them.

I'm not sure this has ever been a problem in the past has it?

Consider something like:

    while(*a++ = *b++);

I don't see how that's vague or ugly, and rewriting is just making it
worse IMO.


  --cw
