From: Sam Leffler <sam@errno.com>
Subject: Re: Asynchronous crypto layer.
Date: Sat, 30 Oct 2004 23:35:28 -0700
Message-ID: <418487B0.7090203@errno.com>
References: <Xine.LNX.4.44.0410310103270.28198-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, jamal <hadi@cyberus.ca>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
In-Reply-To: <Xine.LNX.4.44.0410310103270.28198-100000@thoron.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Fri, 29 Oct 2004, Sam Leffler wrote:
> 
> 
>>And a paper I wrote explains how I fixed many of the problems with the 
>>openbsd code in freebsd.
>>
>>http://www.usenix.org/publications/library/proceedings/bsdcon03/tech/leffler_crypto/leffler_crpto_html/
> 
> 
> Thanks, that's a useful reference.
> 
> For handling overload of crypto hardware, I was thinking of falling back
> to software processing (really, I guess this is just load balancing
> between hardware and software).

I did a prototype scheduler (never committed) that took into account 
per-device performance metrics and outstanding operations.  The s/w 
crypto driver was just part of the mix.  As a result fallback on 
overload and using s/w crypto for small operands (where the setup 
overhead is too costly) just fell out.

	Sam
