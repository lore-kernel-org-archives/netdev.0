From: Sam Leffler <sam@errno.com>
Subject: Re: Asynchronous crypto layer.
Date: Fri, 29 Oct 2004 13:00:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4182A175.8050706@errno.com>
References: <1099062483.1023.21.camel@jzny.localdomain>	<Xine.LNX.4.44.0410291213380.21689-100000@thoron.boston.redhat.com> <20041029204551.06caaf4b@zanzibar.2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: James Morris <jmorris@redhat.com>, jamal <hadi@cyberus.ca>,
        netdev@oss.sgi.com, cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041029204551.06caaf4b@zanzibar.2ka.mipt.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov wrote:
> On Fri, 29 Oct 2004 12:16:35 -0400 (EDT)
> James Morris <jmorris@redhat.com> wrote:
> 
> 
>>On 29 Oct 2004, jamal wrote:
>>
>>
>>>On Fri, 2004-10-29 at 10:06, Evgeniy Polyakov wrote:
>>>
>>>
>>>
>>>>If we have a hardware accelerator chip, than we _already_ have improvements 
>>>>with even the worst async crypto layer, since software and hardware 
>>>>will work in parrallel.
>>>
>>>Thats what i am hoping - and theory points to it. Numbers, numbers
>>>please ;->
>>
>>There's an OpenBSD paper which demonstrates the usefulness of crypto
>>hardware for reducing cpu contention.  I can't get to their web site now,
>>but it's there somewhere under a security link.
> 
> 
> Asynchronous crypto layer was written under impression of those paper.
> OpenBSD layer is very good, but it has some nitpics some of which are really
> not good, but I hope all of them are resolved in my driver.
> 
> You can find paper for example there: http://www.madchat.org/crypto/ocf.pdf

And a paper I wrote explains how I fixed many of the problems with the 
openbsd code in freebsd.

http://www.usenix.org/publications/library/proceedings/bsdcon03/tech/leffler_crypto/leffler_crpto_html/

In the same proceedings you'll also find a horrible paper I wrote about 
some performance tuning I did in my IPsec implementation that uses the 
crypto infrastructure.

http://www.usenix.org/publications/library/proceedings/bsdcon03/tech/full_papers/leffler_ipsec/leffler_ipsec_html/

	Sam
