From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [patch] Bluetooth: fix ->alloc_skb() error checking
Date: Mon, 16 Dec 2013 23:57:18 +0300
Message-ID: <20131216205718.GF5443@mwanda>
References: <20131216202857.GB19601@elgon.mountain>
 <CAJdJm_O9q3YgpjTQexbLvMm8ViViu+MrmRCqPwQDDUzaxVQYUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Gustavo Padovan <gustavo@padovan.org>,
	Johan Hedberg <johan.hedberg@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	BlueZ development <linux-bluetooth@vger.kernel.org>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Anderson Lizardo <anderson.lizardo@openbossa.org>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAJdJm_O9q3YgpjTQexbLvMm8ViViu+MrmRCqPwQDDUzaxVQYUg@mail.gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 04:35:25PM -0400, Anderson Lizardo wrote:
> Hi Dan,
> 
> On Mon, Dec 16, 2013 at 4:28 PM, Dan Carpenter <dan.carpenter@oracle.com> wrote:
> > @@ -2413,8 +2413,8 @@ static struct sk_buff *l2cap_create_basic_pdu(struct l2cap_chan *chan,
> >
> >         skb = chan->ops->alloc_skb(chan, count + L2CAP_HDR_SIZE,
> >                                    msg->msg_flags & MSG_DONTWAIT);
> > -       if (IS_ERR(skb))
> > -               return skb;
> > +       if (skb)
> > +               return ERR_PTR(-ENOMEM);
> 
> It should be "!skb" above right?
> 

Gar....  I'm so sorry about that.

regards,
dan carpenter

