From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] tun: fix carrier on/off status
Date: Tue, 29 Jan 2013 15:45:00 -0500 (EST)
Message-ID: <20130129.154500.1135013581072988248.davem@davemloft.net>
References: <3592886.xagLc7Uij9@jason-thinkpad-t430s>
	<20130128101111.GB5337@redhat.com>
	<20130128103801.GA6648@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com, toralf.foerster@gmx.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130128103801.GA6648@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Mon, 28 Jan 2013 12:38:02 +0200

> Commit c8d68e6be1c3b242f1c598595830890b65cea64a removed carrier off call
> from tun_detach since it's now called on queue disable and not only on
> tun close.  This confuses userspace which used this flag to detect a
> free tun. To fix, put this back but under if (clean).
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Applied.
