From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: [Bluetooth] recursive locking in l2cap_sock_accept/bt_accept_dequeue
Date: Sun, 17 Sep 2006 21:32:10 +0300
Message-ID: <20060917183210.GA24913@ee.oulu.fi>
References: <20060917113646.GA27178@ee.oulu.fi> <1158495506.6665.0.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ee.oulu.fi ([130.231.61.23]:34731 "EHLO ee.oulu.fi")
	by vger.kernel.org with ESMTP id S932209AbWIQScN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Sep 2006 14:32:13 -0400
To: Marcel Holtmann <marcel@holtmann.org>
Content-Disposition: inline
In-Reply-To: <1158495506.6665.0.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Sep 17, 2006 at 02:18:26PM +0200, Marcel Holtmann wrote:
> Hi Pekka,
> 
> > Got this from a 2.6.18rc7-based fedora-devel kernel:
> > 
> > =============================================
> > [ INFO: possible recursive locking detected ]
> > 2.6.17-1.2647.fc6 #1

> > sdpd/4955 is trying to acquire lock:
> >  (sk_lock-AF_BLUETOOTH){--..}, at: [<f0cea241>] bt_accept_dequeue+0x26/0xc6 [bluetooth]
> 
> what where you doing when this happened?
Hiya

Hmn. Plugged my USB BT dongle in, started gnome-obex-server and sent a few
pictures from my cellphone to the box, nothing fancy.. Bluetooth daemons
running obviously at this time...


