From: "David S. Miller" <davem@redhat.com>
Subject: Re: Bluetooth BUG() in set_sk_owner().
Date: Mon, 15 Sep 2003 16:02:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030915160200.5c93b8e0.davem@redhat.com>
References: <1063184337.32473.529.camel@hades.cambridge.redhat.com>
	<20030911182223.2e9b7118.davem@redhat.com>
	<1063616050.21195.67.camel@hades.cambridge.redhat.com>
	<1063619827.28891.507.camel@pegasus>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: dwmw2@infradead.org, netdev@oss.sgi.com, shemminger@osdl.org,
   maxk@qualcomm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcel Holtmann <marcel@holtmann.org>
In-Reply-To: <1063619827.28891.507.camel@pegasus>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 15 Sep 2003 11:57:01 +0200
Marcel Holtmann <marcel@holtmann.org> wrote:

> >  static struct net_proto_family bnep_sock_family_ops = {
> >  	.family = PF_BLUETOOTH,
> > -	.create = bnep_sock_create
> > +	.create = bnep_sock_create,
> > +	.owner = THIS_MODULE
> >  };
> 
> it is only cosmetic, but put the .owner above the .create.

I applied David's patch with Marcel's requested cosmetic change.

Thanks.
