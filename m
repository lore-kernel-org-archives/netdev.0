From: Baruch Even <baruch@ev-en.org>
Subject: Re: Comparison of several congestion control algorithms
Date: Fri, 03 Jun 2005 00:50:07 +0100
Message-ID: <429F9B2F.8030507@ev-en.org>
References: <4298E045.9050009@ev-en.org> <20050602.163512.10298458.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, shemminger@osdl.org, doug.leith@nuim.ie
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050602.163512.10298458.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Baruch Even <baruch@ev-en.org>
> Date: Sat, 28 May 2005 22:19:01 +0100
> 
> 
>>I wanted to point you to a comparison of congestion control algorithm
>>done at the Hamilton Institute. These experiments compare Scalable-TCP,
>>High-Speed TCP, FAST-TCP, BIC-TCP, H-TCP and Standard TCP. They compared
>>  fairness, compatibility with TCP and link utilisation.
>>
>>You can find the results and a report at http://hamilton.ie/net/eval/
> 
> 
> Nice work, I enjoyed this paper very much.
> 
> There is something that none of these papers mention, but is essential
> for interpreting results.  Did you use interfaces with TSO enabled?

I did not do these experiments myself, but to the best of my knowledge,
none of the experiments done so far in Hamilton have used the TSO feature.

This is in part because of the start of the work that was based on 2.4
kernels and even as far as the 2.6.6 kernel which had disabled TSO once
it saw SACKs. This made TSO unusable for our needs.

AFAIK, the tests reported in that document used kernel 2.6.6.

Baruch
