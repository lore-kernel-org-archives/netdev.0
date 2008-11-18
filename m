From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Tue, 18 Nov 2008 22:10:04 +0300
Message-ID: <20081118191004.GB14329@ioremap.net>
References: <20081112135828.GA30946@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA6124F@NASANEXMB10.na.qualcomm.com> <20081112174114.GA4743@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61260@NASANEXMB10.na.qualcomm.com> <20081112181134.GA5396@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA61272@NASANEXMB10.na.qualcomm.com> <20081112191400.GA6291@ioremap.net> <FCC0EC655BD1AE408C047268D1F5DF4C3BA6128D@NASANEXMB10.na.qualcomm.com> <20081112214601.GA19547@ioremap.net> <7e0dd21a0811181049i45c4ffd6md964f6acfa0d4c79@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Lovich, Vitali" <vlovich@qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:59991 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750844AbYKRTKI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2008 14:10:08 -0500
Content-Disposition: inline
In-Reply-To: <7e0dd21a0811181049i45c4ffd6md964f6acfa0d4c79@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2008 at 07:49:00PM +0100, Johann Baudy (johaahn@gmail.com) wrote:
> Currently, we are executing sock_alloc_send_skb() to allocate a new
> skb from socket.
> Then, we replace destructor sock_wfree() with our destructor
> packet_skb_destruct() which executes sock_wfree() once status of
> packet frame (associated to skb data) has been given back to user
> (status changed).
> 
> Is this way ok ?
> Or shall we implement our own sock_alloc_send_skb()?

If it meets your needs it is of course ok, but it has additional memory
management checks and other socket management bits. If it does not
matter, than everything is ok.

-- 
	Evgeniy Polyakov
