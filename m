From: jamal <hadi@cyberus.ca>
Subject: Re: PATCH: IPSEC acquire in presence of multiple managers
Date: 25 Mar 2005 19:54:31 -0500
Message-ID: <1111798470.1090.774.camel@jzny.localdomain>
References: <1111795927.1089.749.camel@jzny.localdomain>
	 <20050326003058.GA22930@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        Shinta Sugimoto <shinta.sugimoto@ericsson.com>,
        netdev <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050326003058.GA22930@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-25 at 19:30, Herbert Xu wrote:

> One problem though is that if theal real KM is dead but the passive
> monitor is still there then the kernel will have to wait for the
> larval states to time out.
> 
> It can happen without the patch too if the KM dies after the message
> is delivered.  This will make it slightly more likely.
> 

Agreed. 

> I guess that's something we'll just have to live with.

Well its useful even if we could just run "ip mon" to look at acquires
going across.

If i understood correctly pfkey: the kernel can be told when a KM is
about to die or just came back up using an empty acquire message by the
KM. I dont think we support this at the moment from looking at the code.
It seems that we dont support any acquires from userspace to kernel
which in theory could be triggered by some apps (I saw OSPF;->) trying 
to get a SA. Is this common behavior?

cheers,
jamal
