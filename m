From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/3] fix buggy IEEE80211_CRYPT_* selects
Date: Sun, 06 Mar 2005 13:00:50 -0500
Message-ID: <422B4552.5000504@pobox.com>
References: <200503041237.j24Cbb69026470@shell0.pdx.osdl.net> <42289BDF.1080409@pobox.com> <20050304221014.GJ3327@stusta.de> <4228DF62.4000205@pobox.com> <20050304230718.GL3327@stusta.de> <20050306090936.GA31890@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Adrian Bunk <bunk@stusta.de>, akpm@osdl.org, davem@davemloft.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050306090936.GA31890@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Sat, Mar 05, 2005 at 12:07:18AM +0100, Adrian Bunk wrote:
> 
>>The way kconfig currently works, you have to ensure that the 
>>dependencies of what you select are fulfilled.
> 
> 
> Yes Adrian's right.  In the other places where we select CRYPTO
> symbols, we always make sure that CRYPTO itself is selected.  See
> net/ipv4/Kconfig for example.

I would rather fix Kconfig.  If we are selecting X_1 -- which explicitly 
depends on X -- when Kconfig should automatically select X.

It is completely illogical to duplicate a dependency chain each time you 
wish to select a symbol.

	Jeff
