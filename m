From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPV6_V6ONLY Support, v2 (is Re: [PATCH] IPv6: Allow Both
Date: Fri, 25 Oct 2002 10:46:44 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210251044410.23582-100000@netcore.fi>
References: <200210241624.UAA02873@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: yoshfuji@linux-ipv6.org, <davem@redhat.com>, <netdev@oss.sgi.com>,
   <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200210241624.UAA02873@sex.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 24 Oct 2002 kuznet@ms2.inr.ac.ru wrote:
> > tcp4       0      0  127.0.0.1.53           *.*                    LISTEN
> > tcp4       0      0  193.166.4.206.53       *.*                    LISTEN
> > tcp4       0      0  193.166.187.10.53      *.*                    LISTEN
> > tcp6       0      0  *.53                   *.*                    LISTEN
> ...
> > Will this work too?
> 
> No.
> 
> The question follows: what the hell does it make this? What is special
> in ipv4 that it needs to bind to its addresses? With IPV6_V6ONLY connections
> to all the IPv4 addresses but listed ones will be refused. I guess it is
> not _that_ thing which bind expects.

I'm not sure I understand what you mean.  Note that the last line is 
_tcp6_:

tcp6       0      0  *.53                   *.*                    LISTEN

So, I belive using IPV6_V6ONLY it should indeed work.

(The reasoning in Bind is that you can bind to addresses _only_ in IPv4 
but you don't have to.  It's done in these cases.  For IPv6, it's 
all-or-nothing.)

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
