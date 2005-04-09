From: Indrek Kruusa <indrek.kruusa@tuleriit.ee>
Subject: Re: Fw: Re: 2.6.12-rc2-mm2
Date: Sat, 09 Apr 2005 19:14:20 +0300
Message-ID: <4257FF5C.2050609@tuleriit.ee>
References: <E1DK25V-0005Ye-00@gondolin.me.apana.org.au>
Reply-To: indrek.kruusa@tuleriit.ee
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1DK25V-0005Ye-00@gondolin.me.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Andrew Morton <akpm@osdl.org> wrote:
>  
>
>>dmesg is not clean though:
>>
>>TCP: time wait bucket table overflow
>>TCP: time wait bucket table overflow
>>TCP: time wait bucket table overflow
>>printk: 392 messages suppressed.
>>
>>What I did:
>>- "bombing" httpd with JMeter (from another computer)
>>    
>>
>
>This is normal.  The number of TCP connections held by
>your server in the TIME_WAIT state is exceeding
>tcp_max_tw_buckets.
>
>Check out tcp(7) on what this means and how it may or
>may not be a problem for you.
>  
>
Wait a moment.... with kernel 2.6.10-oci7 (Sam) load average is 3-4x 
lower and system does not reach this tcp_max_tw_buckets limit. If it is 
desired I can do more tests with different kernels.

Indrek
