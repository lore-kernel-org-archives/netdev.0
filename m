From: "Stephen Biggs" <yrgrknmxpzlk@gawab.com>
Subject: Re: [patch 4/5] net/ipv6/ip6_flowlabel.c: copy_to_user return code
Date: Mon, 07 Mar 2005 09:13:42 +0200
Message-ID: <422C1B46.21973.35151C@localhost>
References: <20050307.073213.32943613.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
To: yoshfuji@linux-ipv6.org, davem@davemloft.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org, domen@coderock.org
In-reply-to: <20050307.073843.09980515.yoshfuji@linux-ipv6.org>
Content-description: Mail message body
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mr. Hideaki,

Thank you very much (domo arigato gozaimasu) for your feedback.  Please 
see below for my comments.

On 7 Mar 2005 at 7:38, B wrote:

> In article <20050307.073213.32943613.yoshfuji@linux-ipv6.org> (at Mon, 07 Mar 2005 07:32:13 +0900 (JST)), YOSHIFUJI Hideaki /  $B5HF#1QL@ (B <yoshfuji@linux-ipv6.org> says:
> 
> > In article <20050306222118.401D11ED3D@trashy.coderock.org> (at Sun, 06 Mar 2005 23:21:17 +0100), domen@coderock.org says:
> > 
> > > 
> > > compile warning cleanup - handle copy_to/from_user error 
> > > returns
> > 
> > Wrong. You introduce a leak.
> 
> Ah, sorry, not really,

Actually, you are correct.  This is one of my first attempts at a patch 
submittal and this is one of a few patches where I did not check for side 
effects.  I will try very much not to make that same mistake again.

> but I still think it is wrong:
> fl_intern() insert it to hash, and
> then you freed up the memory.
> I believe this is wrong.

Yes, you are completely correct, and thank you for catching this.

I will submit a more correct patch shortly.

> 
> --yoshfuji
> 
