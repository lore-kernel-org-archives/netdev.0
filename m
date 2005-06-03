From: Baruch Even <baruch@ev-en.org>
Subject: Re: Comparison of several congestion control algorithms
Date: Fri, 03 Jun 2005 14:42:52 +0100
Message-ID: <42A05E5C.9050408@ev-en.org>
References: <4298E045.9050009@ev-en.org>	<20050602.163512.10298458.davem@davemloft.net>	<429F9B2F.8030507@ev-en.org> <20050602.165341.63126720.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org, doug.leith@nuim.ie
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050602.165341.63126720.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Baruch Even <baruch@ev-en.org>
> Date: Fri, 03 Jun 2005 00:50:07 +0100
> 
> 
>>This is in part because of the start of the work that was based on 2.4
>>kernels and even as far as the 2.6.6 kernel which had disabled TSO once
>>it saw SACKs. This made TSO unusable for our needs.
>>
>>AFAIK, the tests reported in that document used kernel 2.6.6.
> 
> 
> Sure SACKs turn off TSO currently,  but you'll have them enabled
> at the beginning until the first loss and this affects how fast
> the cwnd will grow.
> 
> If you have e1000 cards, for example, you're getting TSO enabled
> by default.
> 
> You really need to look into this, as it has a real and very
> non-trivial effect on all of the results you obtained.

I checked that now and ethtool -k shows TSO to be disabled after boot.
Since all the test scripts are not playing with ethtool I can be sure
that TSO was off during all of our tests.

Baruch
