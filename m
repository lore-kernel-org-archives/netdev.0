From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BK PATCH] [IPV6] Merge Specification Conformity Improvements
Date: Tue, 14 Sep 2004 00:01:58 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040914.000158.76078150.yoshfuji@linux-ipv6.org>
References: <20040913.231732.94153456.yoshfuji@linux-ipv6.org>
	<Pine.LNX.4.44.0409131725250.22572-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@oss.sgi.com, vnuorval@tcs.hut.fi,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: pekkas@netcore.fi
In-Reply-To: <Pine.LNX.4.44.0409131725250.22572-100000@netcore.fi>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <Pine.LNX.4.44.0409131725250.22572-100000@netcore.fi> (at Mon, 13 Sep 2004 17:29:20 +0300 (EEST)), Pekka Savola <pekkas@netcore.fi> says:

> However, if someone would be forging redirects, the comment would no 
> longer hold.
> 
> I don't know the implications in this case: whether the code needs to 
> have different assumptions wrt. source of redirects, or whether this 
> is just a wording issue in the comment above.

I think we're protected (at least) as the standards says.
eg.
 - off-link attacks
 - redirect from non-router for the destination
etc.

I'm not sure if we have other things we can do against this issue.

I think other on-link issues (including "forging" issues) 
will be solved by SEND (SEcuring Neighbor Discovery).

--yoshfuji
