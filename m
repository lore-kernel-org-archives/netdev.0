From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: IPSEC: on behavior of acquire
Date: Sat, 2 Apr 2005 18:00:19 +0400
Message-ID: <20050402140019.GA13017@yakov.inr.ac.ru>
References: <1112405144.1096.33.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>,
        psec-tools-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1112405144.1096.33.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> a) -ERESTART is the correct signal to return

Right behaviour is to behave like ARP. A few of packets are queued,
no errors (until timeout), no blocking.

Alexey
