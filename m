From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/2] NET: Multiqueue network device support implementation.
Date: Tue, 10 Apr 2007 21:04:10 +1000
Message-ID: <E1HbE8w-0000LY-00@gondolin.me.apana.org.au>
References: <D5C1322C3E673F459512FB59E0DDC329029E400C@orsmsx414.amr.corp.intel.com>
Cc: jengelh@linux01.gwdg.de, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: peter.p.waskiewicz.jr@intel.com (Waskiewicz Jr, Peter P)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753488AbXDJLEh@vger.kernel.org>
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329029E400C@orsmsx414.amr.corp.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> wrote:
>
>> >@@ -3356,6 +3370,7 @@ void free_netdev(struct net_device *dev)
>> >     /* will free via device release */
>> >     put_device(&dev->dev);
>> > #else
>> >+    kfree((char *)dev->egress_subqueue);
>> >     kfree((char *)dev - dev->padded);
>> > #endif
>> > }
>> 
>> Ahem. Explain that cast.
> 
>        This can be removed if needed; however, I'm just copying what
> the other kfree()'s are doing in this function.  Any instance of a
> typecast that I introduced in these patches are just following what
> others have done in that section of the code.  So the cast is just for
> consistency in this particular area.  If you'd like me to remove it, I
> can do that.

The other cast is there for the subtraction, not the kfree...

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
