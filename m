From: Kyle McMartin <kyle@debian.org>
Subject: Re: [PATCH] IPsec: add support for Twofish and Serpent
Date: Fri, 15 Aug 2003 13:42:43 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030815174243.GC3119@imladris.debian.net>
References: <20030814180857.GA4205@netppl.fi> <Pine.LNX.4.44.0308142324310.29579-100000@netcore.fi> <20030814191259.435945cf.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030814191259.435945cf.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Aug 14, 2003 at 07:12:59PM -0700, David S. Miller wrote:
> I totally disagree, choice is everything.
> 
> That's why we allow NULL crypto algorithms.  Not doing
> so turns this into a political thing, which I decidedly
> do not want our IPSEC implementation to be all about.
>
> And therefore I will add the patch.
>
Thank you, David. I completely agree with allowing users to choose
which algorithms they wish to deploy. 
 
> When using pfkeyv2 sockets, yes you have to assign a number and then
> the APP has to be aware of it.  This just shows how bogus it is to use
> fixed numbers instead of strings to select crypto algorithms.
>
Again, I agree. Especially given the limitations of using the
private ESP id space, since there is no new RFC delegating
additions yet.

Regards,
-- 
Kyle McMartin <kyle@debian.org>
1024D/191FCD8A - 331A 9468 C04D 3A76 5C56  BA68 7EB7 92DF 191F CD8A
2048R/F515317D -   68 A9 0D 28 1B DF 8D 42  0F CC AF 98 A8 D5 A4 04
