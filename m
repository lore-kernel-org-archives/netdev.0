From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [12/*] [IPSEC] Handle local_df in IPv4
Date: Wed, 16 Mar 2005 03:25:37 +0900 (JST)
Message-ID: <20050316.032537.72822422.yoshfuji@linux-ipv6.org>
References: <20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314212557.23f0ab09.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, kaber@trash.net, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
To: davem@davemloft.net, herbert@gondor.apana.org.au
In-Reply-To: <20050314212557.23f0ab09.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050314212557.23f0ab09.davem@davemloft.net> (at Mon, 14 Mar 2005 21:25:57 -0800), "David S. Miller" <davem@davemloft.net> says:

> > I was going to do the same thing to IPv6.  Unfortunately it seems
> > that we don't have any local_df support over there.  That is, we
> > always fragment outbound UDP/raw packets.  Did I miss something?
> 
> I have no idea offhand.  Perhaps Yoshifuji can figure it out?

Currently, yes.
And, I know this is one of places we may need to revisit...

--yoshfuji
