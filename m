From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.6.8.1 IPv6 Routing Problem
Date: Mon, 20 Sep 2004 08:08:36 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409200806460.22679-100000@netcore.fi>
References: <20040919074605.GJ6005@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>,
        <davem@davemloft.net>, <netdev@oss.sgi.com>,
        <usagi-users@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
In-Reply-To: <20040919074605.GJ6005@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 19 Sep 2004, Harald Welte wrote:
> Apparently this happens when you 
> 
> 1) insmod ipv6
> 2) ifconfig your interfaces up
> 3) only now ifconfig 'lo' up.
> 
> This happened due to a typo in my script :(  If 'lo' exists prior to the
> other interfaces, everything seems to work as usual.
> 
> Is this desired or accidential and/or documented behaviour?

AFAIK, it's not documented, but known among developers (in general): 
there's a lot of magic tied to the loopback interface, and lots of 
things (like ND) break very badly if it's not always up and running 
appropriately..

This has bitten people so many times that it might be useful to try to
mitigate the problem somehow, if feasible...

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
