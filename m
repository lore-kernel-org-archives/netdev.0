From: jamal <hadi@cyberus.ca>
Subject: Re: IPSEC: on behavior of acquire
Date: 02 Apr 2005 16:42:48 -0500
Message-ID: <1112478168.1088.337.camel@jzny.localdomain>
References: <1112405144.1096.33.camel@jzny.localdomain>
	 <20050402140019.GA13017@yakov.inr.ac.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        kaber@trash.net, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050402140019.GA13017@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-04-02 at 09:00, Alexey Kuznetsov wrote:
> Hello!
> 
> > a) -ERESTART is the correct signal to return
> 
> Right behaviour is to behave like ARP. A few of packets are queued,
> no errors (until timeout), no blocking.

Herbert also mentions something along the same lines in his email. 
This would make a lot of sense!
Is the state machine going to look something along the same lines as
ARP? i.e incomplete->reachable etc?

What would be a good code to return when you queue the packet?

cheers,
jamal
