From: AndyLiebman@aol.com
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Mon, 28 Feb 2005 17:25:17 EST
Message-ID: <147.4096aff0.2f54f44d@aol.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, terryg@axian.com, netdev@oss.sgi.com,
        davem@davemloft.net, akpm@osdl.org
To: yoshfuji@linux-ipv6.org
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In a message dated 2/23/2005 11:42:42 A.M. Eastern Standard Time,  
yoshfuji@linux-ipv6.org writes:
In article  <b9.522b6602.2f4df280@aol.com> (at Wed, 23 Feb 2005 09:51:44 
EST),  AndyLiebman@aol.com says:

> Should I bother to apply this patch, or  should I wait for you to make this 
 
> last change? What did you  think about my comment that the Oops only 
occurred  
> when the  Ethernet cable had been unplugged during operation? 

Well, not sure, but  I think it is worth trying.

Thanks.

--yoshfuji
Hi Yoshi,  

I just thought I would let you know that I applied the patch to the  2.6.10 
kernel and recompiled. It seems to have made the Oops go away. At least,  I 
can't make the Oops happen any more by unplugging the Ethernet cables during  
operation and then shutting down. 

I might add that when I tried to apply  the patch with:

patch --dry-run -p1 -d dir < patchfile

I got all kinds of errors about this line or that line. I can't remember  
what they were. In the end, I VERY CAREFULLY cut and pasted your patch, and  
removed the lines the patch was supposed to remove. 

Did you attempt to  apply the patch? Anyway, looks good. 
 
Regards, 
Andy Liebman
 
