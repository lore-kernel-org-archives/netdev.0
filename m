From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2.6]: Fix device leaks in mirred action
Date: Thu, 04 Nov 2004 15:58:39 +0100
Message-ID: <418A439F.2010401@trash.net>
References: <4189CC6A.9040007@trash.net> <1099576439.1038.147.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1099576439.1038.147.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:

>>It also leaks a reference when a mirred action
>>is replaced.
>>    
>>
>
>How? Is this patch supposed to fix that?
>  
>
+                       if (ovr)
+                               dev_put(p->dev);
                        p->dev = dev;

By dropping the reference before replacing it.

Regards
Patrick
