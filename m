From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: 2.6.7-rc3: unregister_netdevice: waiting for tun0 to become free. Usage count = 1
Date: Thu, 17 Jun 2004 23:07:39 +0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617190739.GB10925@ms2.inr.ac.ru>
References: <20040614124402.GA28519@gondor.apana.org.au> <20040616193731.GB29781@ms2.inr.ac.ru> <20040616130950.6aadde3c.davem@redhat.com> <20040616203748.GA30675@ms2.inr.ac.ru> <20040616134711.499209c9.davem@redhat.com> <20040617081722.GA8559@gondor.apana.org.au> <20040617083303.GA8810@gondor.apana.org.au> <20040617101016.44512cb1.davem@redhat.com> <20040617172449.GA10303@ms2.inr.ac.ru> <20040617105324.554c631b.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, schwab@suse.de, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040617105324.554c631b.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> It occurs, via synchronize_net(), but this happens before NETDEV_UNREGISTER
> event is sent out.  Is it sufficient?  I think not,

Agreed.

>						 and that we need to
> add another call in unregister_netdevice() right before final dev_put().

This should be enough.

Alexey
