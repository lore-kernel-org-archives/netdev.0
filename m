From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH 05/11] pcmcia: do not use io_req_t when calling
 pcmcia_request_io()
Date: Sun, 01 Aug 2010 11:04:37 -0700
Message-ID: <1280685877.12579.7.camel@localhost.localdomain>
References: <20100801125749.GA2564@comet.dominikbrodowski.net>
	 <1280667550-3040-5-git-send-email-linux@dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-pcmcia@lists.infradead.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-ide@vger.kernel.org,
	linux-usb@vger.kernel.org, laforge@gnumonks.org,
	linux-mtd@lists.infradead.org, linux-bluetooth@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-serial@vger.kernel.org,
	Michael Buesch <mb@bu3sch.de>
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <linux-serial-owner@vger.kernel.org>
In-Reply-To: <1280667550-3040-5-git-send-email-linux@dominikbrodowski.net>
Sender: linux-serial-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dominik,

> Instead of io_req_t, drivers are now requested to fill out
> struct pcmcia_device *p_dev->resource[0,1] for up to two ioport
> ranges. After a call to pcmcia_request_io(), the ports found there
> are reserved, after calling pcmcia_request_configuration(), they may
> be used.
> 
> CC: netdev@vger.kernel.org
> CC: linux-wireless@vger.kernel.org
> CC: linux-ide@vger.kernel.org
> CC: linux-usb@vger.kernel.org
> CC: laforge@gnumonks.org
> CC: linux-mtd@lists.infradead.org
> CC: linux-bluetooth@vger.kernel.org
> CC: alsa-devel@alsa-project.org
> CC: linux-serial@vger.kernel.org
> CC: Michael Buesch <mb@bu3sch.de>
> Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>

for the drivers/bluetooth/ pieces.

Acked-by: Marcel Holtmann <marcel@holtmann.org>

Regards

Marcel


