From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] Using Fwmark as SPD filter.
Date: Sun, 20 Mar 2005 17:10:21 +0100
Message-ID: <423DA06D.6070603@trash.net>
References: <E1DCazI-0003sx-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ludo Stellingwerff <ludo@protactive.nl>, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DCazI-0003sx-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Ludo Stellingwerff <ludo@protactive.nl> wrote:
> 
>>In general, is this work a waste of time or am I hitting something here?
> 
> 
> Yes you're hitting the right spot :)
> 
> This is a planned feature.  We just need to fix the bundle structure
> so that they live in the flow cache instead of the policy to make this
> workable.

Agreed. I had a look at putting the bundles in the flow cache, it seems
to me this needs the xfrm resolution first since resolving the bundle
would be done in flow cache resolver and we can't sleep in there.
Once that's done it looks like a simple task.

Regards
Patrick
