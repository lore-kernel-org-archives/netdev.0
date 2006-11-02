From: David Brownell <david-b@pacbell.net>
Subject: Re: [linux-usb-devel] [PATCH 2/2] usbnet: use MII hooks only if CONFIG_MII is enabled
Date: Thu, 2 Nov 2006 12:19:22 -0800
Message-ID: <200611021219.27950.david-b@pacbell.net>
References: <Pine.LNX.4.64.0610231618510.3962@g5.osdl.org> <200610311136.54058.david-b@pacbell.net> <20061101012346.GB27968@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-usb-devel@lists.sourceforge.net,
	Randy Dunlap <randy.dunlap@oracle.com>, akpm@osdl.org,
	zippel@linux-m68k.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, link@miggy.org,
	Christoph Hellwig <hch@infradead.org>, torvalds@osdl.org,
	greg@kroah.com, toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp108.sbc.mail.mud.yahoo.com ([68.142.198.207]:12878 "HELO
	smtp108.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S1751036AbWKBUkb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 15:40:31 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061101012346.GB27968@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 31 October 2006 5:23 pm, Adrian Bunk wrote:

>         select MII if USB_NET_AX8817X!=n || USB_NET_MCS7830!=n

Thing is, I'm seeing that get morphed inside Kconfig to "select MII" in
some cases ... the "if x != n" gets ignored, MII can't be deselected.

That looks to me like a Kconfig dependency engine bug, so I'm just
noting it here rather than fixing it.  I guess it's not quite enough
of a Prolog engine ... ;)

- Dave

