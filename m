From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: [PATCH] IPv6: Improvement of Source Address Selection
Date: Thu, 10 Oct 2002 17:29:38 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0210101724030.9287-100000@netcore.fi>
References: <20021006.033351.33728380.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: netdev@oss.sgi.com, <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
In-Reply-To: <20021006.033351.33728380.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 6 Oct 2002, YOSHIFUJI Hideaki / [iso-2022-jp] 吉藤英明 wrote:

Dave, Alexey.. I think there has to be a high-level decision on how to
proceed here.  I'm referring to the optimization.  TCP or other
connection-oriented protocols use this one per connection; UDP and the
like probably once per packet.  The latter is at least quite undesirable,
as you pointed out.

The question is how one can proceed here, what kind of caching or a 
the type of approach taken.

Putting the stuff in the routing table could work, but then this algorithm
would have to be re-run always when there are changes in any address in
the node.  There might be other ways.

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
