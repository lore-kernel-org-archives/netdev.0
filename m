From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Wed, 05 Oct 2016 12:15:34 -0700
Message-ID: <1475694934.1941.1.camel@perches.com>
References: <20161003085640.GA8130@amd>
         <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
         <1475689996.6105.11.camel@perches.com> <20161005191103.GA25972@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>, trivial@kernel.org,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0017.hostedemail.com ([216.40.44.17]:52354 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753002AbcJETPj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 15:15:39 -0400
In-Reply-To: <20161005191103.GA25972@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-05 at 21:11 +0200, Pavel Machek wrote:
> On Wed 2016-10-05 10:53:16, Joe Perches wrote:
> > On Wed, 2016-10-05 at 13:14 +0200, Marcel Holtmann wrote:
> > > Hi Pavel,
> > > 
> > > > bluetooth.h is not part of user API, so __ variants are not neccessary
> > > > here.
> > > > 
> > > > Signed-off-by: Pavel Machek <pavel@ucw.cz>
> > > > 
> > > > diff --git a/include/net/bluetooth/bluetooth.h b/include/net/bluetooth/bluetooth.h
> > 
> > []
> > > > struct bt_skb_cb {
> > > > -	__u8 pkt_type;
> > > > -	__u8 force_active;
> > > > -	__u16 expect;
> > > > -	__u8 incoming:1;
> > > > +	u8 pkt_type;
> > > > +	u8 force_active;
> > > > +	u16 expect;
> > > > +	u8 incoming:1;
> > > > 	union {
> > > > 		struct l2cap_ctrl l2cap;
> > > > 		struct hci_ctrl hci;
> > 
> > 
> > trivia:
> > 
> > It's generally faster to use bool instead of u8 foo:1;
> 
> Ok, but I'm not changing that in this patch.
> (And actually, bool will take a lot more memory, right?)

No worries, and bool is the same size as u8.
> 
