From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [5/*] [IPSEC] Use XFRM_MSG_* instead of XFRM_SAP_*
Date: Tue, 12 Apr 2005 17:17:05 +0900
Message-ID: <425B8401.1010609@linux-ipv6.org>
References: <1112702604.1089.119.camel@jzny.localdomain>	 <20050409105452.GA7171@gondor.apana.org.au>	 <20050409111244.GB7171@gondor.apana.org.au>	 <20050409111551.GA7378@gondor.apana.org.au>	 <20050410074849.GA13259@gondor.apana.org.au>	 <20050410090250.GA26022@gondor.apana.org.au>	 <1113142510.1091.294.camel@jzny.localdomain>	 <425A0F00.8070509@linux-ipv6.org> <1113218805.1089.357.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1113218805.1089.357.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Herbert and Jamal,

jamal wrote:
> On Mon, 2005-04-11 at 01:45, Masahide NAKAMURA wrote:
> 
>>>Do you have anymore patches? If not i can give these a quick test;
>>>Masahide has a better test setup and if he has time he should as well.
>>
>>I can, but about 24 hours later. I'll test it there is no update and
>>if it isn't too late then.
>>

short report:
My testing is not completed but, I've tested below and it is fine:
 add/del/flush SP and their notifications through netlink (using modified iproute2/ip).

 new "xfrm_userpolicy_delete" works fine on this case;
 used byid=1 when deleting SP with specifying SP index.

I'll test the rest case (17 hours later):
- using pfkey
- using both sockets

Thanks,


-- 
Masahide NAKAMURA
