From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/3] fix buggy IEEE80211_CRYPT_* selects
Date: Sun, 06 Mar 2005 14:13:47 -0500
Message-ID: <422B566B.3040801@pobox.com>
References: <200503041237.j24Cbb69026470@shell0.pdx.osdl.net> <42289BDF.1080409@pobox.com> <20050304221014.GJ3327@stusta.de> <4228DF62.4000205@pobox.com> <20050304230718.GL3327@stusta.de> <20050306090936.GA31890@gondor.apana.org.au> <422B4552.5000504@pobox.com> <20050306191029.GM5070@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, akpm@osdl.org,
        davem@davemloft.net, netdev@oss.sgi.com
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050306191029.GM5070@stusta.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> On Sun, Mar 06, 2005 at 01:00:50PM -0500, Jeff Garzik wrote:
> 
>>Herbert Xu wrote:
>>
>>>On Sat, Mar 05, 2005 at 12:07:18AM +0100, Adrian Bunk wrote:
>>>
>>>
>>>>The way kconfig currently works, you have to ensure that the 
>>>>dependencies of what you select are fulfilled.
>>>
>>>
>>>Yes Adrian's right.  In the other places where we select CRYPTO
>>>symbols, we always make sure that CRYPTO itself is selected.  See
>>>net/ipv4/Kconfig for example.
>>
>>I would rather fix Kconfig.  If we are selecting X_1 -- which explicitly 
>>depends on X -- when Kconfig should automatically select X.
>>
>>It is completely illogical to duplicate a dependency chain each time you 
>>wish to select a symbol.
> 
> 
> I asked about the first example of my last email:
>   What values of the variables A-E do you expect exactly if the user 
>   turns on F?
> 
> If you expect this to work, which unambiguous solution do you propose 
> for this example?

If that information is missing, it should re-prompt the user, as it does 
for a few other cases.

	Jeff
