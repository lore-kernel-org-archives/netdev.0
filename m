From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NET]: Fix deletion of local addresses only varying in
 prefix length
Date: Sat, 05 Mar 2005 01:46:42 +0100
Message-ID: <42290172.7020403@trash.net>
References: <20050304012003.GA31837@postel.suug.ch> <E1D78DN-0002te-00@gondolin.me.apana.org.au> <20050304131419.GE31837@postel.suug.ch> <20050304233212.GA27421@gondor.apana.org.au> <20050305002910.GJ31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050305002910.GJ31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> I've been thinking about this since yesterday and the best solution I
> came up so far is to encode it in one of the yet unused bits in
> the prefixlength field. After all we're only using 5bits of it. What
> i'm thinking of in particular is to encode it as in 1 bit wildcard
> flag 5 bits prefix length.

I think that would be ok. Unrelated to this: for IFA_ADDRESS we don't
do an exact match, perhaps we should also do this for IFA_LOCAL for
consistency.

Regards
Patrick
