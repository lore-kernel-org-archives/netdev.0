From: Pekka Nikander <pekka.nikander@nomadiclab.com>
Subject: Re: [Infrahip] Re: [hipl-users] Re: [PATCH 2.6.12.2] XFRM: BEET IPsec mode for Linux
Date: Fri, 29 Jul 2005 17:45:24 +0200
Message-ID: <B9CA81E3-5A80-4629-8D32-42A8C37142E2@nomadiclab.com>
References: <E1Dy6gb-00044G-00@gondolin.me.apana.org.au> <1122651216.25842.67.camel@odysse>
Mime-Version: 1.0 (Apple Message framework v733)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, infrahip@hiit.fi
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <1122651216.25842.67.camel@odysse>
To: diego.beltrami@hiit.fi
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Surely BEET will work also for AH with minor changes, even though we
> only tried the ESP encapsulation.

I wouldn't be so sure.  IIRC, tunnel mode is not specified for AH but  
for ESP only.  Consequently, defining BEET mode for AH might be  
pretty tricky.  OTOH, I don't know the linux IPsec implementation so  
that it might be possible to make BEET to "work" for AH, for some  
value of "work", but it probably would require some careful thinking  
to define the exact semantics, like what addresses (inner or outer)  
are covered by the AH integrity protection, what does the integrity  
protection really assert, etc.

--Pekka
