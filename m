From: Michal Ludvig <mludvig@suse.cz>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 17:28:34 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <418261A2.5070302@suse.cz>
References: <1099030958.4944.148.camel@uganda>	<1099053738.1024.104.camel@jzny.localdomain>	<20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>	<1099062483.1023.21.camel@jzny.localdomain> <20041029193720.53235ec3@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041029193720.53235ec3@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Evgeniy Polyakov told me that:
> On 29 Oct 2004 11:08:03 -0400 jamal <hadi@cyberus.ca> wrote:
> 
>> On Fri, 2004-10-29 at 10:06, Evgeniy Polyakov wrote:
>> 
>>> I agree that multigigahertz box will beat my HIFN card, but I 
>>> doubt it can beat 1gghz VIA.
>> 
>> The VIA is an interesting one; but it would still be interesting to
>>  see comparisons. Actually I should say a good comparison will be 
>> with a dual opteron >= 2Ghz which i have no doubt will smoke a xeon
>> - all in s/ware.
> 
> He-he, dual Opteron? It costs as 5 Via boards :)
> 
> ok, I will follow this plan: I will create simple block device like 
> cryptoloop, it will be _really_ simple without any kind of 
> portability and/or stability (I hope it will be one day, at least it 
> took so for 2.4) and I will measure async vs sync.

Then I could give the numbers for dual (and quad-) Opteron as well ;-))

But make sure that your cryptodriver could take advantage of SMP!

> Then Michal can measure it's fcrypt driver also.

I'll have to port it to acrypto first. But I'll do so :-)

Michal Ludvig
- --
SUSE Labs                    mludvig@suse.cz
(+420) 296.542.396        http://www.suse.cz
Personal homepage http://www.logix.cz/michal
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFBgmGfDDolCcRbIhgRAvpjAJ4+YPJh3+UTtuBvuaU2lfHaHzhNeQCbBJo9
QGUpOlP/OifPWLmhPpnmayI=
=16lO
-----END PGP SIGNATURE-----
