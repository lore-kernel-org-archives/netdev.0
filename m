From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Wed, 05 Oct 2016 10:53:16 -0700
Message-ID: <1475689996.6105.11.camel@perches.com>
References: <20161003085640.GA8130@amd>
         <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>, Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-10-05 at 13:14 +0200, Marcel Holtmann wrote:
> Hi Pavel,
> 
> > bluetooth.h is not part of user API, so __ variants are not neccessary
> > here.
> > 
> > Signed-off-by: Pavel Machek <pavel@ucw.cz>
> > 
> > diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
[]
> > struct bt_skb_cb {
> > -	__u8 pkt_type;
> > -	__u8 force_active;
> > -	__u16 expect;
> > -	__u8 incoming:1;
> > +	u8 pkt_type;
> > +	u8 force_active;
> > +	u16 expect;
> > +	u8 incoming:1;
> > 	union {
> > 		struct l2cap_ctrl l2cap;
> > 		struct hci_ctrl hci;

trivia:

It's generally faster to use bool instead of u8 foo:1;
