From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: Re: [5/*] [IPSEC] Use XFRM_MSG_* instead of XFRM_SAP_*
Date: Wed, 13 Apr 2005 14:07:41 +0900
Message-ID: <425CA91D.1030506@linux-ipv6.org>
References: <1112702604.1089.119.camel@jzny.localdomain>	 <20050409105452.GA7171@gondor.apana.org.au>	 <20050409111244.GB7171@gondor.apana.org.au>	 <20050409111551.GA7378@gondor.apana.org.au>	 <20050410074849.GA13259@gondor.apana.org.au>	 <20050410090250.GA26022@gondor.apana.org.au>	 <1113142510.1091.294.camel@jzny.localdomain>	 <425A0F00.8070509@linux-ipv6.org>	 <1113218805.1089.357.camel@jzny.localdomain>	 <425B8401.1010609@linux-ipv6.org> <1113313023.1966.79.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca, Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <1113313023.1966.79.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello Jamal and Herbert,

jamal wrote:
> On Tue, 2005-04-12 at 04:17, Masahide NAKAMURA wrote:
> 
> 
>>short report:
>>My testing is not completed but, I've tested below and it is fine:
>> add/del/flush SP and their notifications through netlink (using modified iproute2/ip).
>>
>> new "xfrm_userpolicy_delete" works fine on this case;
>> used byid=1 when deleting SP with specifying SP index.
>>
>>I'll test the rest case (17 hours later):
>>- using pfkey
>>- using both sockets
>>
> 
> 
> I did basic testing with pfkey generated events (policy/state) showing
> up in both. The vice-versa also looks good.

Thanks, Jamal.
I'm sorry to be late, I've also tested pfkey, both sockets, and using racoon
(on 2.6.12-rc2 + Jamal's patch + Herbert's 6 patches).

# If somebody is interested in, modified iproute2 for the kernel can be found at:
# http://www.linux-ipv6.org/~nakam/iproute2-xfrm-event/iproute2-xfrm-event-20050413.tar.gz
# a patch against the latest iproute2 bk tree
# http://www.linux-ipv6.org/~nakam/iproute2-xfrm-event/iproute2-xfrm-event-20050413.diff
# This iproute2 change will be sent to Stephen after the kernel released.


> Herbert, try to push forward to Dave.

Agreed.

Regards,

-- 
Masahide NAKAMURA
